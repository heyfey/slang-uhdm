// § genLpSysCallArgName239
// an unnamed if-generate block, $bits of a generate-local typedef and $size of a local array
module top #(parameter int N = 4) (input logic [N-1:0] r, output logic o);
  if (N > 2) begin
    typedef logic [N+1:0] w_t;
    logic [2:0] arr [5];
    localparam int A = $bits(w_t);
    localparam int B = $size(arr);
    assign o = r[0] ^ (A > B);
  end else begin
    assign o = r[0];
  end
endmodule
