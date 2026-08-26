// r10uvm154 arm A — § enumWrittenNegDecLit154 across ENUM BASES.
// The head's own shape is `tdbit_e` (a typedef `bit [31:0]` base, exactly
// uvm-1.2's `typedef bit [`UVM_REG_CVR_WIDTH-1:0] uvm_reg_cvr_t`), but the law
// says the base NEVER participates, so every base carries the same constant.
// Names/orders/widths deliberately vary so an agreeing arm is not a
// self-confirming one (RESUME.md §9).
package pk_a154;
   typedef bit [31:0]  cvrmask_t;
   typedef logic [7:0] octet_t;
   typedef int         plainint_t;

   typedef enum                { none_all = -1, none_two = 2      } none_e;
   typedef enum int            { i_all    = -1, i_seven = 7       } int_e;
   typedef enum integer        { g_all    = -9, g_four  = 4       } integer_e;
   typedef enum bit [31:0]     { b32_all  = -1, b32_five = 5      } bit32_e;
   typedef enum byte           { by_all   = -2, by_six  = 6       } byte_e;
   typedef enum shortint       { sh_all   = -1, sh_nine = 9       } shortint_e;
   typedef enum longint        { lo_all   = -4294967296, lo_one = 1 } longint_e;
   typedef enum int unsigned   { ui_all   = -1, ui_three = 3      } uint_e;
   typedef enum logic [31:0]   { l32_all  = -2147483648, l32_x = 11 } logic32_e;
   typedef enum cvrmask_t      { td_all   = -1, td_eight = 8      } tdbit_e;
   typedef enum plainint_t     { ti_all   = -1, ti_ten  = 10      } tdint_e;
endpackage

module top_a154;
   pk_a154::none_e     u_none;
   pk_a154::int_e      u_int;
   pk_a154::integer_e  u_integer;
   pk_a154::bit32_e    u_b32;
   pk_a154::byte_e     u_byte;
   pk_a154::shortint_e u_short;
   pk_a154::longint_e  u_long;
   pk_a154::uint_e     u_uint;
   pk_a154::logic32_e  u_l32;
   pk_a154::tdbit_e    u_td;
   pk_a154::tdint_e    u_ti;
   initial begin
      u_none  = pk_a154::none_all;
      u_int   = pk_a154::i_all;
      u_b32   = pk_a154::b32_all;
      u_td    = pk_a154::td_all;
   end
endmodule
