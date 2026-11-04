// § genLocalEnumConstShared184: an enum declared in a generate-for body, read in the body's process and continuous assignment
module dut (input logic clk, output logic [1:0] y);
  for (genvar i = 0; i < 2; i++) begin : gf
    typedef enum logic {A0, A1} a_e;
    a_e q;
    always_ff @(posedge clk) q <= (q == A0) ? A1 : A0;
    assign y[i] = q == A1;
  end
endmodule
