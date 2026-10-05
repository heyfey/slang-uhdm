// § arrQualDeclFullPath250v
module ma(output logic [3:0] o);
  // pad
  p::a_t v;
  assign v[0] = 4'd1;
  assign o = v[0];
endmodule
