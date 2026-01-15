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
let sReadNumberOfIndexes = 3
let sReadIDs = 4
let sScanReq = 5
let sScanCheck = 6
let sFinish = 7
(* FSM States *)

let circuit (i : I.t) : O.t =
    let open Always in
    let spec = Reg_spec.create ~clock:i.clk ~reset:i.rst () in

    let address = Variable.reg spec ~width:addressWidth in
    (* .mem address pointer *)

    let state = Variable.reg spec ~width:3 in
    let rangesRead = Variable.reg spec ~width:dataWidth in
    let idsRead = Variable.reg spec ~width:dataWidth in
    let nr = Variable.reg spec ~width:dataWidth in
    let ni = Variable.reg spec ~width:dataWidth in
    (* registers and counters *)

    let rangeCount = Variable.reg spec ~width:rangeAddressWidth in
    (* number of ranges stored in BRAM *)

    let tempStart = Variable.reg spec ~width:dataWidth in
    (* temp start storage when reading the pairs *)

    let currentID = Variable.reg spec ~width:dataWidth in
    let scanID = Variable.reg spec ~width:rangeAddressWidth in
    let found = Variable.reg spec ~width:1 in
    (* current ID handling *)

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

    let romEnable = vdd in
    (* Always read the .mem file *)

    let addressIncrement = address.value +:. 1 in
    (* Helper command to increment the address *)

    let fsm =
        Always.(
            compile
            [
                if_ i.rst
                    [
                        address <-- zero addressWidth;
                        state <-- of_int ~width:3 sReadNumberOfRanges;
                        rangesRead <-- zero dataWidth;
                        idsRead <-- zero dataWidth;
                        nr <-- zero dataWidth;
                        ni <-- zero dataWidth;
                        rangeCount <-- zero rangeAddressWidth;
                        tempStart <-- zero dataWidth;
                        currentID <-- zero dataWidth;
                        scanID <-- zero rangeAddressWidth;
                        found <-- gnd;
                        freshCount <-- zero dataWidth;
                        done_ <-- gnd;
                        countValid <-- gnd;
                        finishPulse <-- gnd;

                        rangeWE <-- gnd;
                        rangeAddress <-- zero rangeAddressWidth;
                        rangeLowWData <-- zero dataWidth;
                        rangeHighWData <-- zero dataWidth;
                    ]
                    [
                        countValid <-- gnd;
                        rangeWE <-- gnd;
                        (* default pulses are low *)

                        (* Below is the FSM *)

                        switch state.value
                        [
                            (of_int ~width:3 sReadNumberOfRanges,
                                [ done_ <-- gnd;
                                  finishPulse <-- gnd;
                                  nr <-- i.romData;
                                  rangesRead <-- zero dataWidth;
                                  rangeCount <-- zero rangeAddressWidth;
                                  address <-- addressIncrement;
                                  state <-- of_int ~width:3 sReadRangeStart;
                                ]);

                            (of_int ~width:3 sReadRangeStart,
                                [ if_ (rangesRead.value <: nr.value)
                                    [ tempStart <-- i.romData;
                                      address <-- addressIncrement;
                                      state <-- of_int ~width:3 sReadRangeEnd;
                                    ]
                                    [ state <-- of_int ~width:3 sReadNumberOfIndexes
                                    ]
                                ]);

                            (of_int ~width:3 sReadRangeEnd,
                                let startv = tempStart.value in
                                let endv = i.romData in
                                let lowv = mux2 (startv <=: endv) startv endv in
                                let highv = mux2 (startv <=: endv) endv startv in

                                (* read the end, store the range, and make sure that the low <= high *)

                                [ rangeWE <-- vdd;
                                  rangeAddress <-- rangeCount.value;
                                  rangeLowWData <-- lowv;
                                  rangeHighWData <-- highv;

                                  rangeCount <-- (rangeCount.value +:. 1);
                                  rangesRead <-- (rangesRead.value +:. 1);
                                  address <-- addressIncrement;
                                  state <-- of_int ~width:3 sReadRangeStart;
                                ]);

                            (of_int ~width:3 sReadNumberOfIndexes,
                                [ ni <-- i.romData;
                                  idsRead <-- zero dataWidth;
                                  address <-- addressIncrement;
                                  state <-- of_int ~width:3 sReadIDs;
                                ]);

                            (of_int ~width:3 sReadIDs,
                                [ if_ (idsRead.value <: ni.value)
                                    [ currentID <-- i.romData;
                                      scanID <-- zero rangeAddressWidth;
                                      found <-- gnd;
                                      address <-- addressIncrement;
                                      state <-- of_int ~width:3 sScanReq;
                                    ]
                                    [ state <-- of_int ~width:3 sFinish
                                    ]
                                ]);

                            (of_int ~width:3 sScanReq,
                                [ rangeAddress <-- scanID.value;
                                  state <-- of_int ~width:3 sScanCheck;
                                ]);

                            (of_int ~width:3 sScanCheck,
                                let matchNow = (currentID.value >=: i.rangeLowRData) &: (currentID.value <=: i.rangeHighRData) in
                                let foundNext = found.value |: matchNow in

                                [ found <-- foundNext;

                                  if_ ((scanID.value +:. 1) <: rangeCount.value)
                                      [ scanID <-- (scanID.value +:. 1);
                                        state <-- of_int ~width:3 sScanReq;
                                      ]
                                      [ if_ (foundNext ==: vdd)
                                            [ freshCount <-- (freshCount.value +:. 1) ]
                                            [];
                                        idsRead <-- (idsRead.value +:. 1);
                                        state <-- of_int ~width:3 sReadIDs;
                                      ]
                                ]);

                            (of_int ~width:3 sFinish,
                                [ done_ <-- vdd;

                                  if_ (finishPulse.value ==: gnd)
                                      [ countValid <-- vdd;
                                        finishPulse <-- vdd;
                                      ]
                                      [];

                                  state <-- of_int ~width:3 sFinish;
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
            ~name:"freshFilterPart1"
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
