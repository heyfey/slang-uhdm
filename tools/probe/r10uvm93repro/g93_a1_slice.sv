// r10uvm93 arm A1 -- streaming-concatenation slice_size forms.
// GOLDEN MEASUREMENT: which slice_size shapes does Surelog FOLD to a loc-less
// width constant (compileBits/Reduce::Yes) and which stay a located expression?
// Names deliberately unrelated to their forms (no a_t/b_t/c_t self-confirmation).
package zq93_pk;
  typedef bit [11:0]  murmur_t;      // 12 bits
  typedef logic [4:0] pelican_t;     //  5 bits
  typedef struct packed { byte quill; bit [2:0] rasp; } thicket_t;  // 11 bits
  typedef enum bit [2:0] { GLEAM, HOVER, INKY } lantern_t;          //  3 bits
  parameter int WREN = 7;

  class zebu93;
    bit [63:0] cask;
    int  vessel[];
    byte pebble[];
    function void marlin();
      { << int      { vessel }} = cask;   // integer_atom int
      { << byte     { pebble }} = cask;   // integer_atom byte
      { >> shortint { vessel }} = cask;   // >> direction, atom
      { << longint  { vessel }} = cask;
      { << integer  { vessel }} = cask;
      { << bit      { pebble }} = cask;   // integer_vector
      { << logic    { pebble }} = cask;
      { << reg      { pebble }} = cask;
      { << murmur_t { pebble }} = cask;   // ps_type_identifier: packed vector typedef
      { << thicket_t{ pebble }} = cask;   // ps_type_identifier: struct typedef
      { << lantern_t{ pebble }} = cask;   // ps_type_identifier: enum typedef
      { << 6        { pebble }} = cask;   // numeric literal
      { << WREN     { pebble }} = cask;   // parameter reference
      { << (WREN+2) { pebble }} = cask;   // expression
      { <<          { pebble }} = cask;   // no slice size
      cask = { << int { vessel }};        // RHS-streaming, atom
      cask = { << murmur_t { pebble }};   // RHS-streaming, typedef
      cask = { << 5 { pebble }};          // RHS-streaming, literal
    endfunction
  endclass

  function automatic void grebe(ref bit [63:0] sump, ref byte flit[]);
    { << int      { flit }} = sump;
    { << pelican_t{ flit }} = sump;
    sump = { >> byte { flit }};
  endfunction
endpackage

module zq93_top;
  import zq93_pk::*;
  typedef bit [9:0] cobble_t;
  bit [63:0] tureen;
  byte swale[];
  int  gorse[];
  initial begin
    { << int      { gorse  }} = tureen;   // module procedural, atom
    { << cobble_t { swale  }} = tureen;   // module procedural, local typedef
    { << 4        { swale  }} = tureen;
    tureen = { << shortint { swale }};
  end
  always_comb begin
    { << longint { gorse }} = tureen;
  end
endmodule
