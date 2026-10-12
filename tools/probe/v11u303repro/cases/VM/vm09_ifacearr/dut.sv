// § modArrBoundSelUnstored303
interface ii; logic a; endinterface
module top(output logic o);
  localparam logic [7:0] X = 8'b0000_0101;
  ii u_e [X[2]:0] ();
  assign o = 1'b0;
endmodule
