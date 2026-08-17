interface \i.f.C ();
  logic v;
endinterface

module plaintop (input wire x, output wire y);
  \i.f.C bus ();
  assign y = x;
endmodule
