// § unsignedScalarVecTsAtKeyword137
module top(output logic o);
  task automatic t(input bit unsigned a, output logic unsigned b);
    reg unsigned q;
    q = a; b = q;
  endtask
  logic r;
  initial t(1'b1, r);
  assign o = r;
endmodule
