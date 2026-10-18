// § invalidCaAssignChild404
module child #(parameter els_p = 4)(input [els_p-1:0] a, input w, output [els_p-1:0] s);
  assign s = {els_p {w}} & a;
endmodule
module top; endmodule
