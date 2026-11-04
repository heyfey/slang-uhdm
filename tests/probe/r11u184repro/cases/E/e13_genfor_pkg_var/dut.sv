// § genLocalEnumConstShared184: a package enum typing a variable declared in a generate-for body, read in the body's process
package pk;
  typedef enum logic [1:0] {R0, R1, R2} r_e;
endpackage
module dut (input logic clk, output logic [3:0] y);
  for (genvar i = 0; i < 2; i++) begin : gf
    pk::r_e q;
    always_ff @(posedge clk) q <= (q == pk::R0) ? pk::R1 : pk::R2;
    assign y[2*i +: 2] = q;
  end
endmodule
