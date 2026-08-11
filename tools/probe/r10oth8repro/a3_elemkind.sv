// r10oth8 arm a3 — the ELEMENT-KIND grid, which exists to test the SUPPRESS
// half of the law rather than the ADD half.  The ADD half only ever fires on a
// SIGNED leaf; the SUPPRESS half (`reg->VpiSigned(false)` on the element var)
// is written UNCONDITIONALLY at module scope, so it has to be checked against
// golden for element kinds that are NOT predefined integers — an enum, a
// struct, a class handle, a string, a signed packed vector and, above all, a
// TYPEDEF, since a typedef is how UVM spells almost every element type
// (`uvm_reg_addr_t`, `uvm_bitstream_t`, …) and a typedef of a signed type is
// signed without the keyword appearing at the declaration at all.
typedef byte              b_t;         // signed, via a typedef
typedef bit [7:0]         u8_t;        // unsigned
typedef bit signed [15:0] s16_t;       // signed, via a typedef, keyword inside
typedef int               i_t;         // signed
typedef enum { E0, E1 }   e_t;
typedef struct packed { byte hi; byte lo; } sp_t;

class ec;
  rand b_t     c01_dyn_btd[];       // typedef'd SIGNED byte
  rand u8_t    c02_dyn_u8td[];      // typedef'd UNSIGNED vector
  rand s16_t   c03_dyn_s16td[];     // typedef'd SIGNED vector
  rand i_t     c04_q_itd[$];        // typedef'd signed int, QUEUE
  rand b_t     c05_as_btd[string];  // typedef'd signed byte, ASSOC
  rand e_t     c06_dyn_enum[];      // enum element
  rand sp_t    c07_dyn_struct[];    // packed-struct element
  rand logic signed [3:0] c08_dyn_ls[];  // signed 4-state vector
  rand byte    c09_as_bidx[e_t];    // assoc indexed by an ENUM, signed element
endclass

class hc;
  ec           c10_dyn_h[];         // CLASS-HANDLE element (never `rand`)
  string       c11_q_str[$];        // string element, queue
endclass

module a3_top;
  ec eh;
  hc hh;
  initial begin
    eh = new();
    hh = new();
  end
endmodule
