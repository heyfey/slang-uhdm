// r10v68 arm v11 — the SAME bare/floating declarations at DISTANCE 0, where the
// PRISTINE emitter already minted sz 64 (i.e. already agreed with golden).
// Any size the patch puts here that is not 64 is a pristine-right ->
// patched-wrong cell.  MEASUREMENT ONLY.
module v11_d0 (output logic [7:0] o);
  var       bv;
  shortreal sr;
  realtime  rt;
  real      rl;
  logic     l1;
  logic [7:0] sink;
  assign impd0 = 1'b0;
  for (genvar i = 5; i < 6; i++) begin : g
    assign impd0 = i;          // implicit net,  distance 0
    assign bv    = i;          // bare var,      distance 0
    assign sr    = i;          // shortreal,     distance 0
    assign rt    = i;          // realtime,      distance 0
    assign rl    = i;          // real,          distance 0
    assign l1    = i;          // 1-bit logic,   distance 0
  end
  assign sink = {4'b0, impd0, bv, l1, (sr > 0.0)} ^ {6'b0, (rt > 0.0), (rl > 0.0)};
  assign o = sink;
endmodule
