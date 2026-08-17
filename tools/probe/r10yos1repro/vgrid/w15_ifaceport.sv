interface ib ();
  logic v;
endinterface

module \a.b.C (ib bus, input wire x);
  assign bus.v = x;
endmodule
