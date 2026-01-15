open Hardcaml
open Signal
(* Made by Aidan Ruck *)

let maxRanges = 4096
let () = ignore maxRanges
(* this was giving an error but isnt needed so *)

let addressWidth = 20
let dataWidth = 64
let rangeAddressWidth = 12
(* Same variables as VHDL (-ish), these are the parameters *)

module I = struct
    type t =
        { clk : Signal.t
        ; rst : Signal.t
        ; romData : Signal.t
        ; rangeLowRData : Signal.t
        ; rangeHighRData : Signal.t
        }
end
(* This will be the input of the DUT *)

module O = struct
    type t =
        { romAddress : Signal.t
        ; romEnable : Signal.t
        ; freshCount : Signal.t
        ; done_ : Signal.t
        ; countValid : Signal.t
        ; rangeWE : Signal.t
        ; rangeAddress : Signal.t
        ; rangeLowWData : Signal.t
        ; rangeHighWData : Signal.t
        }
end
(* This is the output for the DUT *)

let sReadNumberOfRanges = 0
let sReadRangeStart = 1
let sReadRangeEnd = 2
let sSortSetup = 3
let sSortReqA = 4
let sSortReadA = 5
let sSortReqB = 6
let sSortReadB = 7
let sSortCompare = 8
let sSortWriteA = 9
let sSortWriteB = 10
let sMergeReqFirst = 11
let sMergeReadFirst = 12
let sMergeReqNext = 13
let sMergeReadNext = 14
let sMergeDecide = 15
let sFinish = 16
(* FSM States *)

let circuit (i : I.t) : O.t =
    let open Always in
    let spec = Reg_spec.create ~clock:i.clk ~reset:i.rst () in

    let address = Variable.reg spec ~width:addressWidth in
    (* .mem address pointer *)

    let state = Variable.reg spec ~width:5 in
    let rangesRead = Variable.reg spec ~width:dataWidth in
    let nr = Variable.reg spec ~width:dataWidth in
    (* registers and counters *)

    let rangeCount = Variable.reg spec ~width:rangeAddressWidth in
    (* number of ranges stored in BRAM *)

    let tempStart = Variable.reg spec ~width:dataWidth in
    (* temp start storage when reading the pairs *)

    let freshCount = Variable.reg spec ~width:dataWidth in
    let done_ = Variable.reg spec ~width:1 in
    let countValid = Variable.reg spec ~width:1 in
    let finishPulse = Variable.reg spec ~width:1 in
    (* output handling *)

    let rangeWE = Variable.reg spec ~width:1 in
    let rangeAddress = Variable.reg spec ~width:rangeAddressWidth in
    let rangeLowWData = Variable.reg spec ~width:dataWidth in
    let rangeHighWData = Variable.reg spec ~width:dataWidth in
    (* BRAM interface signals *)

    let sortOuterIndex = Variable.reg spec ~width:rangeAddressWidth in
    let sortInnerIndex = Variable.reg spec ~width:rangeAddressWidth in
    let tempRangeLowA = Variable.reg spec ~width:dataWidth in
    let tempRangeHighA = Variable.reg spec ~width:dataWidth in
    let tempRangeLowB = Variable.reg spec ~width:dataWidth in
    let tempRangeHighB = Variable.reg spec ~width:dataWidth in
    (* sort handling *)

    let mergeRangeIndex = Variable.reg spec ~width:rangeAddressWidth in
    let currentRangeLow = Variable.reg spec ~width:dataWidth in
    let currentRangeHigh = Variable.reg spec ~width:dataWidth in
    let nextRangeLow = Variable.reg spec ~width:dataWidth in
    let nextRangeHigh = Variable.reg spec ~width:dataWidth in
    (* merge handling *)

    let romEnable = vdd in
    (* Always read the .mem file *)

    let addressIncrement = address.value +:. 1 in
    (* Helper command to increment the address *)

    let oneRangeAddress = of_int ~width:rangeAddressWidth 1 in
    let oneData = of_int ~width:dataWidth 1 in
    let zeroData = zero dataWidth in

    let sortLimitInner =
        ((rangeCount.value -:. 1) -: sortOuterIndex.value)
    in

    let sortDone =
        (rangeCount.value <=:. 1) |: (sortOuterIndex.value >=: (rangeCount.value -:. 1))
    in
    (* sort helper signals *)

    let fsm =
        Always.(
            compile
            [
                if_ i.rst
                    [
                        address <-- zero addressWidth;
                        state <-- of_int ~width:5 sReadNumberOfRanges;
                        rangesRead <-- zero dataWidth;
                        nr <-- zero dataWidth;
                        rangeCount <-- zero rangeAddressWidth;
                        tempStart <-- zero dataWidth;

                        freshCount <-- zero dataWidth;
                        done_ <-- gnd;
                        countValid <-- gnd;
                        finishPulse <-- gnd;

                        rangeWE <-- gnd;
                        rangeAddress <-- zero rangeAddressWidth;
                        rangeLowWData <-- zero dataWidth;
                        rangeHighWData <-- zero dataWidth;

                        sortOuterIndex <-- zero rangeAddressWidth;
                        sortInnerIndex <-- zero rangeAddressWidth;
                        tempRangeLowA <-- zero dataWidth;
                        tempRangeHighA <-- zero dataWidth;
                        tempRangeLowB <-- zero dataWidth;
                        tempRangeHighB <-- zero dataWidth;

                        mergeRangeIndex <-- zero rangeAddressWidth;
                        currentRangeLow <-- zero dataWidth;
                        currentRangeHigh <-- zero dataWidth;
                        nextRangeLow <-- zero dataWidth;
                        nextRangeHigh <-- zero dataWidth;
                    ]
                    [
                        countValid <-- gnd;
                        rangeWE <-- gnd;
                        (* default pulses are low *)

                        (* Below is the FSM *)

                        switch state.value
                        [
                            (of_int ~width:5 sReadNumberOfRanges,
                                [ done_ <-- gnd;
                                  finishPulse <-- gnd;
                                  freshCount <-- zero dataWidth;

                                  nr <-- i.romData;
                                  rangesRead <-- zero dataWidth;
                                  rangeCount <-- zero rangeAddressWidth;
                                  address <-- addressIncrement;

                                  state <-- of_int ~width:5 sReadRangeStart;
                                ]);

                            (of_int ~width:5 sReadRangeStart,
                                [ if_ (rangesRead.value <: nr.value)
                                    [ tempStart <-- i.romData;
                                      address <-- addressIncrement;
                                      state <-- of_int ~width:5 sReadRangeEnd;
                                    ]
                                    [ state <-- of_int ~width:5 sSortSetup
                                    ]
                                ]);

                            (of_int ~width:5 sReadRangeEnd,
                                let startValue = tempStart.value in
                                let endValue = i.romData in
                                let lowValue = mux2 (startValue <=: endValue) startValue endValue in
                                let highValue = mux2 (startValue <=: endValue) endValue startValue in

                                (* read the end, store the range, and make sure that the low <= high *)

                                [ rangeWE <-- vdd;
                                  rangeAddress <-- rangeCount.value;
                                  rangeLowWData <-- lowValue;
                                  rangeHighWData <-- highValue;

                                  rangeCount <-- (rangeCount.value +:. 1);
                                  rangesRead <-- (rangesRead.value +:. 1);
                                  address <-- addressIncrement;
                                  state <-- of_int ~width:5 sReadRangeStart;
                                ]);

                            (of_int ~width:5 sSortSetup,
                                [ sortOuterIndex <-- zero rangeAddressWidth;
                                  sortInnerIndex <-- zero rangeAddressWidth;
                                  rangeAddress <-- zero rangeAddressWidth;

                                  if_ sortDone
                                      [ state <-- of_int ~width:5 sMergeReqFirst ]
                                      [ state <-- of_int ~width:5 sSortReqA ]
                                ]);

                            (of_int ~width:5 sSortReqA,
                                [ rangeAddress <-- sortInnerIndex.value;
                                  state <-- of_int ~width:5 sSortReadA;
                                ]);

                            (of_int ~width:5 sSortReadA,
                                [ tempRangeLowA <-- i.rangeLowRData;
                                  tempRangeHighA <-- i.rangeHighRData;
                                  state <-- of_int ~width:5 sSortReqB;
                                ]);

                            (of_int ~width:5 sSortReqB,
                                [ rangeAddress <-- (sortInnerIndex.value +: oneRangeAddress);
                                  state <-- of_int ~width:5 sSortReadB;
                                ]);

                            (of_int ~width:5 sSortReadB,
                                [ tempRangeLowB <-- i.rangeLowRData;
                                  tempRangeHighB <-- i.rangeHighRData;
                                  state <-- of_int ~width:5 sSortCompare;
                                ]);

                            (of_int ~width:5 sSortCompare,
                                [
                                    if_ (tempRangeLowA.value >: tempRangeLowB.value)
                                        [ state <-- of_int ~width:5 sSortWriteA ]
                                        [
                                            if_ ((sortInnerIndex.value +: oneRangeAddress) <: sortLimitInner)
                                                [ sortInnerIndex <-- (sortInnerIndex.value +: oneRangeAddress);
                                                  state <-- of_int ~width:5 sSortReqA;
                                                ]
                                                [ sortInnerIndex <-- zero rangeAddressWidth;
                                                  sortOuterIndex <-- (sortOuterIndex.value +: oneRangeAddress);
                                                  if_ sortDone
                                                      [ state <-- of_int ~width:5 sMergeReqFirst ]
                                                      [ state <-- of_int ~width:5 sSortReqA ];
                                                ]
                                        ]
                                ]);

                            (of_int ~width:5 sSortWriteA,
                                [ rangeWE <-- vdd;
                                  rangeAddress <-- sortInnerIndex.value;
                                  rangeLowWData <-- tempRangeLowB.value;
                                  rangeHighWData <-- tempRangeHighB.value;

                                  state <-- of_int ~width:5 sSortWriteB;
                                ]);

                            (of_int ~width:5 sSortWriteB,
                                [ rangeWE <-- vdd;
                                  rangeAddress <-- (sortInnerIndex.value +: oneRangeAddress);
                                  rangeLowWData <-- tempRangeLowA.value;
                                  rangeHighWData <-- tempRangeHighA.value;

                                  if_ ((sortInnerIndex.value +: oneRangeAddress) <: sortLimitInner)
                                      [ sortInnerIndex <-- (sortInnerIndex.value +: oneRangeAddress);
                                        state <-- of_int ~width:5 sSortReqA;
                                      ]
                                      [ sortInnerIndex <-- zero rangeAddressWidth;
                                        sortOuterIndex <-- (sortOuterIndex.value +: oneRangeAddress);
                                        if_ sortDone
                                            [ state <-- of_int ~width:5 sMergeReqFirst ]
                                            [ state <-- of_int ~width:5 sSortReqA ];
                                      ]
                                ]);

                            (of_int ~width:5 sMergeReqFirst,
                                [ mergeRangeIndex <-- zero rangeAddressWidth;
                                  rangeAddress <-- zero rangeAddressWidth;
                                  state <-- of_int ~width:5 sMergeReadFirst;
                                ]);

                            (of_int ~width:5 sMergeReadFirst,
                                [ currentRangeLow <-- i.rangeLowRData;
                                  currentRangeHigh <-- i.rangeHighRData;
                                  mergeRangeIndex <-- oneRangeAddress;

                                  if_ (rangeCount.value <=:. 1)
                                      [ state <-- of_int ~width:5 sFinish ]
                                      [ state <-- of_int ~width:5 sMergeReqNext ];
                                ]);

                            (of_int ~width:5 sMergeReqNext,
                                [ rangeAddress <-- mergeRangeIndex.value;
                                  state <-- of_int ~width:5 sMergeReadNext;
                                ]);

                            (of_int ~width:5 sMergeReadNext,
                                [ nextRangeLow <-- i.rangeLowRData;
                                  nextRangeHigh <-- i.rangeHighRData;
                                  state <-- of_int ~width:5 sMergeDecide;
                                ]);

                            (of_int ~width:5 sMergeDecide,
                                let currentSegmentLength =
                                    (currentRangeHigh.value -: currentRangeLow.value) +: oneData
                                in
                                let currentHighPlus1 =
                                    currentRangeHigh.value +: oneData
                                in
                                let mergeable =
                                    nextRangeLow.value <=: currentHighPlus1
                                in
                                let mergedHigh =
                                    mux2 (nextRangeHigh.value >: currentRangeHigh.value) nextRangeHigh.value currentRangeHigh.value
                                in
                                let newCurrentLow =
                                    mux2 mergeable currentRangeLow.value nextRangeLow.value
                                in
                                let newCurrentHigh =
                                    mux2 mergeable mergedHigh nextRangeHigh.value
                                in
                                let lengthToAddNow =
                                    mux2 mergeable zeroData currentSegmentLength
                                in
                                let hasMore =
                                    (mergeRangeIndex.value +: oneRangeAddress) <: rangeCount.value
                                in
                                let finalSegmentLength =
                                    (newCurrentHigh -: newCurrentLow) +: oneData
                                in
                                [
                                    freshCount <-- (freshCount.value +: lengthToAddNow);

                                    currentRangeLow <-- newCurrentLow;
                                    currentRangeHigh <-- newCurrentHigh;

                                    if_ hasMore
                                        [ mergeRangeIndex <-- (mergeRangeIndex.value +: oneRangeAddress);
                                          state <-- of_int ~width:5 sMergeReqNext;
                                        ]
                                        [ freshCount <-- (freshCount.value +: lengthToAddNow +: finalSegmentLength);
                                          state <-- of_int ~width:5 sFinish;
                                        ]
                                ]);

                            (of_int ~width:5 sFinish,
                                [ done_ <-- vdd;

                                  if_ (finishPulse.value ==: gnd)
                                      [ countValid <-- vdd;
                                        finishPulse <-- vdd;
                                      ]
                                      [];

                                  state <-- of_int ~width:5 sFinish;
                                ])
                        ]
                    ]
            ]
        )
    in

    ignore fsm;

    { O.romAddress = address.value
    ; romEnable
    ; freshCount = freshCount.value
    ; done_ = done_.value
    ; countValid = countValid.value
    ; rangeWE = rangeWE.value
    ; rangeAddress = rangeAddress.value
    ; rangeLowWData = rangeLowWData.value
    ; rangeHighWData = rangeHighWData.value
    }
;;

let () =
    let clk = input "clk" 1 in
    let rst = input "rst" 1 in
    let romData = input "romData" dataWidth in

    let rangeLowRData = input "rangeLowRData" dataWidth in
    let rangeHighRData = input "rangeHighRData" dataWidth in

    let i = { I.clk; rst; romData; rangeLowRData; rangeHighRData } in
    let o = circuit i in

    let circuit =
        Circuit.create_exn
            ~name:"freshFilterPart2"
            [ output "romAddress" o.romAddress
            ; output "romEnable" o.romEnable
            ; output "freshCount" o.freshCount
            ; output "done" o.done_
            ; output "countValid" o.countValid

            ; output "rangeWE" o.rangeWE
            ; output "rangeAddress" o.rangeAddress
            ; output "rangeLowWData" o.rangeLowWData
            ; output "rangeHighWData" o.rangeHighWData
            ]
    in
    Rtl.print Verilog circuit
