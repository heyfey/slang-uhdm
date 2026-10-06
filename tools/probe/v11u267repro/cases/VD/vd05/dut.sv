// § pkgQualPatConnSpan267
module pm (input pp::req_t s, output logic o);
  assign o = s.a;
endmodule
module top(output logic o, output logic o2);
  pm u_a(.s(pp::REQ_DEFAULT), .o(o));
  pm u_b(pp::REQ_DEFAULT, o2);
endmodule
