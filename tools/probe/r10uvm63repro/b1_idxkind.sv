// r10uvm63 arm b1 — THE INDEX TYPESPEC OF AN ASSOCIATIVE CLASS PROPERTY, one
// index KIND per line.
//
// THE WITNESS this arm reduces is uvm-1.2 base/uvm_recorder.svh:312 —
//   `local static uvm_recorder m_recorders_by_id[integer];`
// whose index `integer_typespec @312:48-312:55` carries `|vpiSigned:1` in
// golden and NOTHING in ours.  Cell c01_integer is that declaration with the
// element type reduced to `int`.
//
// ONE DECLARATION PER LINE is load-bearing: the extractor keys the INDEX
// typespec by descending from the named property (array_var -> vpiTypespec ->
// array_typespec -> vpiIndexTypespec -> ref_typespec -> vpiActual), so the cell
// id is the NAME, not the line — but a one-per-line layout keeps every index
// typespec at a DISTINCT span, so a shared-object collision is visible.
//
// THE ELEMENT TYPE IS `int` EVERYWHERE ON PURPOSE.  § arrayElemTsSignedParented9
// already owns the ELEMENT typespec's vpiSigned+vpiParent; holding the element
// constant means every difference this arm reports belongs to the INDEX.
class b1c;
  int c01_integer[integer];
  int c02_int[int];
  int c03_byte[byte];
  int c04_shortint[shortint];
  int c05_longint[longint];
  int c06_time[time];
  int c07_intu[int unsigned];
  int c08_byteu[byte unsigned];
  int c09_integeru[integer unsigned];
  int c10_shortintu[shortint unsigned];
  int c11_longintu[longint unsigned];
  int c12_bit[bit];
  int c13_logic[logic];
  int c14_reg[reg];
  int c15_string[string];
  int c16_bitvec[bit [7:0]];
  int c17_logicvec[logic [7:0]];
  int c18_bitsvec[bit signed [7:0]];
  int c19_logicsvec[logic signed [7:0]];
  int c20_intsigned[int signed];
  int c21_bytesigned[byte signed];
endclass

module b1_top;
  b1c h;
  initial h = new();
endmodule
