// r10sd9 GRID CELL g6 — NEGATIVE CONTROL: an ENUM typedef element.  The enum
// arm of classElemVar ALREADY asked sharedAliasTs before this pass; nothing in
// this cell may move.
package pu;
  typedef enum int { AU, BU } tu;
  class cu;
    tu s_enum;
    tu a_enum [string];
  endclass
endpackage
module topu;
  pu::cu hu;
endmodule
