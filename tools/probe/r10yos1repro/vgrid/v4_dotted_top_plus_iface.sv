interface plainif ();
  logic v;
endinterface

module \a.b.C (input wire x, output wire y);
  plainif bus ();
  assign bus.v = x;
  assign y = bus.v;
endmodule
