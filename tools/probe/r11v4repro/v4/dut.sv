// v11u4 ADVERSARIAL v4 — the FOLD-SCOPE substitution shape (the OneNetRange
// cell), an interface with NO parameters, an interface instantiated inside a
// generate FOR, and a receiving module that is itself parameterized with a
// SAME-NAMED parameter.
interface tif #(parameter int width = 1, parameter int lim = width - 1);
  logic [width-1:0] d;
  modport mp (input d);
endinterface

interface noparam_if;
  logic d;
  modport mp (input d);
endinterface

// The receiving module has its OWN `width`, which `ifacePortViewFoldScope`
// substitutes -- so the port view's value is 16, not the declaration's 1.
module middle #(parameter int width = 16) (tif conn, noparam_if np);
  logic z; assign z = conn.d[0] ^ np.d;
endmodule

module leafm #(parameter int width = 5) (tif.mp conn);
  logic z; assign z = conn.d[0];
endmodule

module top;
  localparam int width = 16;
  tif #(width) c1();
  tif #(.width(width)) c2();
  noparam_if np1();
  middle #(.width(width)) m1 (c1, np1);
  middle                  m2 (.conn(c2), .np(np1));
  leafm  #(.width(width)) m3 (.conn(c1.mp));
  for (genvar gi = 0; gi < 2; gi++) begin : gl
    tif #(.width(4)) cg();
    middle mg (.conn(cg), .np(np1));
  end
endmodule
