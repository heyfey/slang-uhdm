// r10svs4repro/v1_empty.sv — VERIFIER arm: the EMPTY PRODUCT CELLS the
// implementer's 46-cell grid skips.  Every cell here is a shape that reaches
// one of the THREE new call sites (ElementSelect / RangeSelect / MemberAccess)
// with a written-`this` base and at least one select, i.e. a shape the shipped
// predicate FIRES on, but whose golden verdict the shipped grid never measured.
//
// The axis the shipped grid never varied: WHAT THE SELECT IS.  Every measured
// cell selects an ELEMENT out of an unpacked collection (dynamic/fixed/queue/
// 2-D/assoc).  A BIT select out of a PACKED vector, a bit select of a
// packed-struct FIELD, a STRING index, and a PARTIAL index of a 2-D array are
// all `ElementSelect`/`RangeSelect` in slang too — same call site, same
// predicate, unmeasured verdict.  Plus: two selects at TWO member levels, a
// select whose element is a CLASS HANDLE that is then dereferenced, a method
// call ON a selected element, a this-path index inside an LVALUE, and the
// increment/concat/system-call positions.
//
// One statement per line; the line number in the dump names the cell.
class Holder;
   byte data[];
endclass

class Chi;
   int fld;
   function void bump(); endfunction
endclass

typedef struct packed { byte f; byte g; } ps_t;

class Vgrid;
   logic [7:0] vec;          // PACKED vector member -> a bit select, not an elem
   logic [7:0] vv [2];       // array OF packed vectors
   ps_t        ps;           // packed struct member
   string      s;            // string member -> s[k] is a byte
   byte        data[];
   byte        aa[];         // for two-level select
   Chi         child[4];     // array of class HANDLES
   Holder      ch;
   int         m2[2][3];
   int         q[$];
   int         r;
   int         m1[3];

   function void f(Vgrid pkt, int k);
      r = this.vec[3];                    // v1  BIT select of a PACKED vector
      r = pkt.vec[3];                     // v2  control: same on a handle
      r = this.vec[5:2];                  // v3  PART select of a packed vector
      r = pkt.vec[5:2];                   // v4  control
      r = this.ps.f[2];                   // v5  bit select of a packed-STRUCT field
      r = pkt.ps.f[2];                    // v6  control
      r = this.vv[k][3];                  // v7  elem-then-bit, packed elem
      r = pkt.vv[k][3];                   // v8  control
      r = this.s[k];                      // v9  STRING index
      r = pkt.s[k];                       // v10 control
      m1 = this.m2[k];                    // v11 PARTIAL index of a 2-D array
      m1 = pkt.m2[k];                     // v12 control
      r = this.child[k].fld;              // v13 handle-in-array, then member
      r = pkt.child[k].fld;               // v14 control
      this.child[k].bump();               // v15 METHOD CALL on a selected elem
      pkt.child[k].bump();                // v16 control
      r = this.ch.data[k] + 1;            // v17 member.member[idx] rvalue
      pkt.data[this.data[k]] = 8'h1;      // v18 this-path AS INDEX in an LVALUE
      r = this.data[k] + pkt.data[k];     // v19 both receivers, one operation
      this.data[k]++;                     // v20 INCREMENT: read AND write
      r = {this.data[k], this.data[k+1]}; // v21 inside a CONCATENATION
      $display("%0d", this.data[k]);      // v22 SYSTEM-call argument
      this.q.push_back(this.data[k]);     // v23 builtin-method arg
      r = (k > 0) ? this.data[k] : 0;     // v24 ternary arm
      case (this.data[k])                 // v25 CASE selector
        8'h0: r = 1;
        default: r = 2;
      endcase
      r = this.aa[this.data[k]];          // v26 this-path index of a this-path
   endfunction
endclass

// A PARAMETERIZED class: the same law, but the scope prefix differs.
class Pgrid #(int W = 4);
   byte data[];
   int  r;
   function void f(int k);
      r = this.data[k];                   // v27 parameterized class
      this.data[k] = 8'h5;                // v28 parameterized class LVALUE
   endfunction
endclass

module mv;
   Vgrid g;
   Pgrid #(8) p;
   initial begin
      if (g != null) g.f(g, 1);
      if (p != null) p.f(1);
   end
endmodule
