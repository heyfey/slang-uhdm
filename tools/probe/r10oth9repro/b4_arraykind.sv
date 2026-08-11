// r10oth9 arm b4 — ALL FOUR ARRAY KINDS, class twin and module twin.
//
// The exporter arm this pass edits is gated on
//   ct.kind == DynamicArrayType || QueueType || AssociativeArrayType
// so FIXED-size arrays are a DIFFERENT arm (TypeEmit's emitArrayVar / the
// class-scope fixed path) and are here as the boundary control: if the law's
// reading is "the element typespec of an UNPACKED array", fixed must agree; if
// it is "the element typespec of a DYNAMIC/QUEUE/ASSOC array", fixed is allowed
// to differ and the difference must be named rather than absorbed.
//
// Bounded queue (`[$:7]`) is separated from unbounded because Surelog compiles
// the bound into a range on the array_var and that is a different code path.
class hc;
  rand byte              h01_fix[4];
  rand byte              h02_dyn[];
  rand byte              h03_q[$];
  rand byte              h04_qb[$:7];
  rand byte              h05_as_str[string];
  rand byte              h06_as_int[int];
  rand byte              h07_as_wild[*];
  rand byte              h08_fix2[4][2];
  rand byte              h09_dyn2[][];
  rand byte              h10_fixdyn[4][];
  rand byte              h11_dynfix[][4];
endclass

module b4_top;
  byte                   i01_fix[4];
  byte                   i02_dyn[];
  byte                   i03_q[$];
  byte                   i04_qb[$:7];
  byte                   i05_as_str[string];
  byte                   i06_as_int[int];
  byte                   i07_as_wild[*];
  byte                   i08_fix2[4][2];
  byte                   i09_dyn2[][];
  byte                   i10_fixdyn[4][];
  byte                   i11_dynfix[][4];
  hc h;
  initial begin
    h = new();
    i02_dyn = new[1];
    i09_dyn2 = new[1];
    i11_dynfix = new[1];
  end
endmodule
