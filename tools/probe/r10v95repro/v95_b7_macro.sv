// r10v95 arm b7 — MACRO BODY vs PLAIN SOURCE for the same select argument
// (the head's own shape: the width is a substituted formal inside a macro).
`define REC(NM, SZ) \
  if (SZ > 16) begin nm_hit = nm_hit + 1; end \
  else begin nm_miss = nm_miss + (SZ); end

`define BITSEL(V) $bits(V)

module b7;
  byte   md [];
  bit [31:0] wide;
  byte   fx [4];
  int    nm_hit, nm_miss;
  int    idx;
  int    plain;
  initial begin
    `REC(a, $bits(md[idx]))
    `REC(b, $bits(wide[3]))
    `REC(c, $bits(fx[2]))
    plain = $bits(md[idx]);
    plain = plain + `BITSEL(wide[7:0]);
  end
endmodule
