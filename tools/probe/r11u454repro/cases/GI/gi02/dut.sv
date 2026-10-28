// § genericIfcPortRunSharedTs454
interface ia; logic x; endinterface
module s(interface a, interface b);
  assign a.x = b.x;
endmodule
module s3(interface q, interface r);
  assign q.x = r.x;
endmodule
module top;
  ia u1(); ia u2();
  s dut(u1, u2);
  s dut2(.a(u2), .b(u1));
  s3 d3(u1, u2);
endmodule
