// vrgg17 v8 — OUTPUT / INOUT port actuals (the inLhs naming branches) and a
// procedural WRITE to the same hier_path text.
interface sif; logic [31:0] value; endinterface
module drv (output logic [3:0] o); assign o = 4'h5; endmodule
module bidi (input wire [3:0] io); endmodule
module top;
  sif arr[20]();
  logic [31:0] w [0:19];
  for (genvar i = 0; i < 2; i++) begin : g
    drv  u_o1 (.o(arr[6+7*i].value[0+:4]));      // OUTPUT port actual
    drv  u_o2 (.o(arr[2+3*i].value[3:0]));       // OUTPUT, simple range
    // (inout removed: a variable cannot bind to inout)
    always_comb w[i] = 32'h0;
  end
endmodule
