// vrgg17 v3 — the POSITION axis: NON-port uses of the identical hier_path text.
interface sif; logic [31:0] value; endinterface
module sink (input logic [3:0] d); endmodule
function automatic logic [3:0] fid (input logic [3:0] a); return a; endfunction
module top;
  sif arr[20]();
  logic [3:0] c1, c2, c3, c4, c5;
  for (genvar i = 0; i < 2; i++) begin : g
    sink u_p1 (.d(arr[6+7*i].value[0+:4]));            // PORT   -> folds
    assign c1 = arr[6+7*i].value[0+:4];                 // cont_assign Rhs
    always_comb c2 = arr[6+7*i].value[0+:4];            // always block
    always @(*) c3 = arr[6+7*i].value[3:0];             // always @* , range
    assign c4 = fid(arr[6+7*i].value[0+:4]);            // FUNCTION ARG
    initial begin c5 = arr[6+7*i].value[0+:4]; end      // initial block
  end
endmodule
