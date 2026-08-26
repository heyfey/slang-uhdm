// r10v155 arm B — TARGET KINDS and TYPEDEF SHAPES, all UNIQUELY named so the
// uniqueness gate cannot decline them.  MEASUREMENT ONLY.
`define MKTD155V(nm, ty) typedef ty nm``_t155v
package pkgB155v;
  class BoxB155v #(parameter type T = int);
    T payload;
  endclass
  class PlainB155v;
    int f;
  endclass
endpackage

module mKind155v;
  import pkgB155v::*;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } outerStructB155v;
  initial begin
    typedef bit                       kBit155v;
    typedef logic [7:0]               kLogic155v;
    typedef int                       kInt155v;
    typedef string                    kString155v;
    typedef PlainB155v                kHandle155v;      // typedef OF A CLASS
    typedef BoxB155v#(int)            kParamCls155v;    // parameterised class
    typedef bit [3:0][1:0]            kPackedArr155v;   // packed array
    typedef int                       kElemQ155v;
    typedef enum bit [1:0] { EB0=0, EB1=1 } kEnum155v;
    typedef struct packed { bit x; bit y; } kStruct155v;
    typedef union packed { bit [1:0] u; bit [1:0] v; } kUnion155v;
    typedef kInt155v                  kTdOfTd155v;      // typedef of a typedef
    typedef outerStructB155v          kTdOfModTd155v;   // typedef of a MODULE td
    `MKTD155V(kMacro155v, byte);                        // macro-expanded typedef

    kBit155v        vBit155v;
    kLogic155v      vLogic155v;
    kInt155v        vInt155v;
    kString155v     vString155v;
    kHandle155v     vHandle155v;
    kParamCls155v   vParamCls155v;
    kPackedArr155v  vPackedArr155v;
    kElemQ155v      vQueue155v [$];
    kElemQ155v      vDyn155v [];
    kElemQ155v      vFixed155v [3];
    kElemQ155v      vAssoc155v [string];
    kEnum155v       vEnum155v;
    kStruct155v     vStruct155v;
    kUnion155v      vUnion155v;
    kTdOfTd155v     vTdOfTd155v;
    kTdOfModTd155v  vTdOfModTd155v;
    kMacro155v_t155v vMacro155v;

    vBit155v = 1'b1;
    vInt155v = 3;
    vString155v = "s";
    vLogic155v = 8'd7;
  end
endmodule

// A FORWARD typedef at module level whose real definition is also at module
// level, plus a stmt-scope typedef of a DIFFERENT unique name — the forward one
// must not move.
module mFwd155v;
  typedef struct packed { bit p; } fwdRealB155v;
  typedef fwdRealB155v fwdAliasB155v;
  initial begin
    typedef byte           localFwdB155v;
    localFwdB155v vLocalFwd155v;   // ?
    fwdAliasB155v vFwdAlias155v;   // control: resolves
    vLocalFwd155v = 8'd9;
  end
endmodule
