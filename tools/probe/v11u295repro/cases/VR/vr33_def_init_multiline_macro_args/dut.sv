// § rawEndLineModel295
`define ADD(x,y) (x+y)
module top(output logic [7:0] o);
  logic [7:0] a = `ADD(8'd1,
     8'd2);
  assign o = a;
endmodule
