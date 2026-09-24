// § implicitNetMintNoFile131
module sub (output logic o);
  initial begin : loop
    o = 1'b0;
    disable loop;
  end
endmodule
module top (output logic o1, output logic o2);
  sub u1(.o(o1));
  sub u2(.o(o2));
endmodule
