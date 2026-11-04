// § genLocalEnumConstShared184: a generate-block enum inside an interface, read in the block's process
interface bus_if #(parameter bit P = 1'b1) (input logic clk);
  logic [1:0] st;
  if (P) begin : g
    typedef enum logic [1:0] {I0, I1, I2} ist_e;
    ist_e q;
    always_ff @(posedge clk) q <= (q == I0) ? I1 : I0;
    assign st = q;
  end
endinterface
module dut (input logic clk, output logic [1:0] y);
  bus_if b (.clk(clk));
  assign y = b.st;
endmodule
