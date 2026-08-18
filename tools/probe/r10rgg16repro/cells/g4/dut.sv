// g4 — the ACTUAL's SPELLING axis: a modport expression `inst.mp`, an
// interface-ARRAY element `arr[0]`, and a PLAIN (non-modport) interface port,
// each at module scope and inside a gen scope.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module plainchild (ifc p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic o0, output logic o1, output logic o2,
            output logic o3, output logic o4, output logic o5);
  ifc #(16, 3) inst ();
  ifc #(8, 2)  inst2 ();
  ifc #(4, 5)  arr [2] ();
  // c1  modport-expression actual, module scope
  child u1 (.p(inst.mp), .o(o0));
  // c2  modport-expression actual, gen scope (base `inst` outside)
  if (1) begin : g2
    child u2 (.p(inst.mp), .o(o1));
  end
  // c3  interface-array ELEMENT actual, module scope
  child u3 (.p(arr[0]), .o(o2));
  // c4  interface-array ELEMENT actual, gen scope
  if (1) begin : g4
    child u4 (.p(arr[1]), .o(o3));
  end
  // c5  PLAIN interface port, module scope
  plainchild u5 (.p(inst2), .o(o4));
  // c6  PLAIN interface port, gen scope
  if (1) begin : g6
    plainchild u6 (.p(inst2), .o(o5));
  end
endmodule
