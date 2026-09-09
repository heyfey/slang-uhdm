// r10uvm225 arm a1_ifkinds — EVERY container kind in an EMPTY-PARENS,
// UNINSTANTIATED interface definition.  The MiniAmiq shape is `k_dyncls225`.
class Ck225;
  int x;
endclass

typedef struct packed { logic [3:0] a; logic [3:0] b; } sp225_t;
typedef struct { int a; string b; } su225_t;
typedef logic [7:0] tv225_t;

interface if225_kinds();
  typedef int ti225_t;   // local typedef: a NAMED associative index
  // --- the CONTROL: no unpacked dimension at all -> no array_net
  Ck225      k_cls225;
  tv225_t    k_tv225;
  int        k_int225;
  logic [3:0] k_pk225;          // PACKED only

  // --- FIXED unpacked (the kind we already mint)
  Ck225      k_fixcls225 [1:0];
  tv225_t    k_fixtv225  [1:0];
  int        k_fixint225 [2];
  logic [3:0] k_fixpk225 [1:0];

  // --- DYNAMIC (MiniAmiq's own three)
  Ck225      k_dyncls225 [];
  tv225_t    k_dyntv225  [];
  int        k_dynint225 [];
  logic [3:0] k_dynpk225 [];

  // --- QUEUE
  Ck225      k_qcls225 [$];
  tv225_t    k_qtv225  [$];
  int        k_qint225 [$];

  // --- ASSOCIATIVE, BUILT-IN index (the reprieved typespec form)
  Ck225      k_ascls225  [string];
  tv225_t    k_astv225   [string];
  int        k_asint225  [int];
  logic [3:0] k_aspk225  [bit];

  // --- ASSOCIATIVE, NAMED index (typespec dropped)
  tv225_t    k_asnamed225 [ti225_t];
  int        k_asnint225  [ti225_t];

  // --- WILDCARD index
  int        k_aswild225 [*];
endinterface

// A ported interface with NO top-level module SEGFAULTS our pristine binary
// (r10uvm225 R-E, pre-existing); every arm therefore carries a top.
module top225_kinds(); endmodule
