// r10oth9 arm b1 — THE CONTROL AND THE TARGET, side by side, in a CLASS and in
// a MODULE.
//
// The pass's discriminator is that the ELEMENT TYPESPEC of a dynamic-array
// property is BARE on our side while the typespec of a PLAIN SCALAR property
// one line below carries `vpiParent` -> its var and `vpiSigned:1` on BOTH
// sides.  This arm is that pair, reduced: `c01_fcs` is the control that already
// passes, `c02_data` is SVSwitch Packet.sv:23 verbatim, `c03_data_norand`
// removes `rand` so the law cannot be a `rand` artefact.
//
// ONE DECLARATION PER LINE is load-bearing: the extractor keys a typespec on
// its SPAN, and the element typespec is spanned at the element-type KEYWORD, so
// the line number IS the cell id.
class bc;
  byte                   c01_fcs;            // CONTROL: plain scalar (passes)
  rand byte              c02_data[];         // TARGET: SVSwitch Packet.sv:23
  byte                   c03_data_norand[];  // TARGET without `rand`
  rand byte              c04_fcs_rand;       // control, with `rand`
endclass

module b1_top;
  byte                   m01_fcs;
  byte                   m02_data[];
  byte                   m03_data2[];
  bc h;
  initial begin
    h = new();
    m02_data = new[1];
    m03_data2 = new[1];
  end
endmodule
