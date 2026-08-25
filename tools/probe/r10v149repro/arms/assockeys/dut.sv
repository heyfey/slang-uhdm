// v149 arm 2 -- ASSOCIATIVE KEYS + DYNAMIC, all of which must NOT enter the
// queue arm, next to two queues that must.  If the bareWrapInst clause is too
// wide it will fire on one of these.
package Nu_pkg;
  typedef enum bit [2:0] { LOW = 3'd1, HIGH = 3'd4 } level_e;
  typedef logic [9:0] key_t;
  class KeyClass;
    int k;
  endclass
  typedef struct {
    int         byIntKey[int];
    int         byStrKey[string];
    int         byWildKey[*];
    int         byTdefKey[key_t];
    int         byEnumKey[level_e];
    real        dynOnly[];
    string      realQueue[$];
    KeyClass    byClassKey[KeyClass];
    shortint    boundedTwo[$:15];
  } keyfaces_t;
  keyfaces_t theKeys;
endpackage

module assockeys_top;
  import Nu_pkg::*;
  keyfaces_t k3;
  initial k3.byIntKey[2] = 5;
endmodule
