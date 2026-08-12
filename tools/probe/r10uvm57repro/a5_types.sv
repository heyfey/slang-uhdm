// r10uvm57repro/a5_types.sv -- EVERY type that can be declared in a block:
// string (the witness), int, byte, a logic vector, an enum, a struct, a class
// handle, a dynamic array, and a TYPEDEF NAME.  Which get a typespec chain?
typedef enum int { E0, E1 } e_t;
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
typedef logic [7:0] byte_t;
class handle_c;
  int x;
endclass

class types_c;
  static function int f(int obj);
    f = obj;
    if (obj == 0) begin
      string      v_string;
      int         v_int;
      byte        v_byte;
      logic [7:0] v_vec;
      e_t         v_enum;
      s_t         v_struct;
      handle_c    v_handle;
      int         v_dynarr[];
      byte_t      v_td;
      v_string = "s";
      v_int = 1;
      v_byte = 2;
      v_vec = 3;
      v_enum = E0;
      v_struct = '0;
      v_handle = null;
      v_dynarr = new[2];
      v_td = 4;
      $display(v_string, v_int, v_byte, v_vec, v_enum, v_struct.a, v_dynarr[0], v_td);
    end
  endfunction
endclass

module a5_types;
  types_c tc;
  initial tc = null;
endmodule
