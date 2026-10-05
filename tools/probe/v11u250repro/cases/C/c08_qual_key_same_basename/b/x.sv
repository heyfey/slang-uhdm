// § arrQualDeclFullPath250v
module mb(output logic [3:0] o);
  import p::*;
  a_t    v;
  assign v[1] = 4'd2;
  assign o = v[1];
endmodule
module top(output logic [3:0] o1, o2);
  ma a(.o(o1));
  mb b(.o(o2));
endmodule
