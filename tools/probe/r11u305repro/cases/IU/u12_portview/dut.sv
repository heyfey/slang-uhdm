// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 1)();
  logic sig;
  logic [7:0] arr [2];
  assign arr[0] = (P) ? {8{sig}} : '0;
  modport mp (input arr);
endinterface
module sub (bif.mp m, output logic [7:0] y);
  assign y = m.arr[0];
endmodule
module top (output logic [7:0] y);
  bif b0();
  sub u (.m(b0.mp), .y(y));
endmodule
