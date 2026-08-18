// r10uvm93 arm A2 -- slice_size EDGE forms + the $bits(<type>) sibling family.
// Deliberately mixes homes (macro vs plain, class-in-module, generate, task)
// and orders so that agreement cannot come from position alone.
`define ZQ93_STREAM(TYP, DST, SRC) { << TYP { DST }} = SRC
`define ZQ93_BITSOF(TYP) $bits(TYP)

package zq93_pk2;
  typedef bit [11:0] murmur_t;
endpackage

module zq93_edge;
  import zq93_pk2::*;
  typedef logic [6:0] fennel_t;
  bit [63:0] tureen;
  byte swale[];
  int  gorse[];
  time tock[];

  initial begin
    { << time     { gorse }} = tureen;              // integer_atom time
    { << zq93_pk2::murmur_t { swale }} = tureen;    // package-scoped ps_type_identifier
    `ZQ93_STREAM(int,   gorse, tureen);             // macro-expanded atom
    `ZQ93_STREAM(byte,  swale, tureen);
    `ZQ93_STREAM(fennel_t, swale, tureen);          // macro-expanded typedef
    `ZQ93_STREAM(3,     swale, tureen);             // macro-expanded literal
  end

  // the $bits(<type>) sibling family, same homes
  localparam int LP_A = $bits(int);
  localparam int LP_B = $bits(byte);
  localparam int LP_C = $bits(fennel_t);
  localparam int LP_D = `ZQ93_BITSOF(shortint);
  int rill;
  initial begin
    rill = $bits(int);
    rill = $bits(logic);
    rill = $bits(fennel_t);
    rill = $bits(tureen);
    rill = $size(gorse);
  end

  if (1) begin : gsc
    byte hollow[];
    initial { << longint { hollow }} = 64'd9;       // inside a generate block
  end

  class inner93;
    byte plume[];
    task nib(input bit [31:0] w);
      { << shortint { plume }} = w;                 // class-in-module task
      { << murmur_t { plume }} = w;
    endtask
  endclass
endmodule
