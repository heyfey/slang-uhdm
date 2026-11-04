// § clsQBoundUntypedParamTs410
class c #(parameter D = 4);
  localparam L = 2;
  byte q[$:D];
  rand int r[$:L];
endclass
module top;
  c #(6) h;
endmodule
