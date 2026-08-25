// r10v126 arm D - ELEMENT SHAPES x DIMENSION SHAPES the patch must NOT touch or
// must get right: queue/dynamic/assoc(int and string key)/2-D/3-D of STRING,
// packed controls that MUST STAY logic/bit, enum / packed struct / unpacked
// struct / class handle elements, and the mixed fixed-then-dynamic shape.
package pk_shp126v;
  typedef enum logic [1:0] { Z_LO = 2'd0, Z_HI = 2'd3 } zcol126v_e;
  typedef struct packed { logic [5:0] top126v; logic [1:0] bot126v; } zpk126v_t;
  typedef struct { real fld126v; string nm126v; } zup126v_t;
  class Cell126v; int n126v; endclass
  class Shapes126v;
    function int probe();
      string      q_str126v [$];
      string      y_str126v [];
      string      ai_str126v [int];
      string      as_str126v [string];
      string      t2_str126v [3][4];
      string      t3_str126v [2][3][2];
      string      mx_str126v [5][];
      logic [9:0] p_lgc126v [2];
      logic       p_bare126v [6];
      bit   [2:0] p_bit126v [3];
      bit         p_bbare126v [7];
      int         p_int126v [4];
      zcol126v_e  e_col126v [2];
      zpk126v_t   e_pkg126v [3];
      zup126v_t   e_upk126v [4];
      Cell126v    e_cls126v [5];
      real        r_arr126v [2][3];
      chandle     h_arr126v [4];
      event       v_arr126v [3];
      q_str126v.push_back("q"); y_str126v = new[2]; ai_str126v[5]="i";
      as_str126v["k"]="s"; t2_str126v[2][3]="t"; t3_str126v[1][2][1]="u";
      mx_str126v[4] = new[3];
      p_lgc126v[1]=10'd5; p_bare126v[5]=1'b1; p_bit126v[2]=3'd4;
      p_bbare126v[6]=1'b0; p_int126v[3]=11;
      e_col126v[1]=Z_HI; e_pkg126v[2].top126v=6'd9; e_upk126v[3].fld126v=1.5;
      e_cls126v[4]=null; r_arr126v[1][2]=2.5; h_arr126v[3]=null;
      return 0;
    endfunction
  endclass
endpackage
