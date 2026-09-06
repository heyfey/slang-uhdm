// r10v177 adversarial arm 3 — THE RE-KIND FACES, RE-ASKED IN A DIFFERENT ORDER
// AND UNDER DIFFERENT NAMES.  g177_b_kinds.sv asks the same question with
// direct-then-alias pairs in one fixed order; this arm interleaves them, puts
// several aliases BEFORE the direct typedef they are built on is used, mixes
// case, and adds the faces the implementer's arm does not carry:
//   * TWO typedefs of ONE enum, both used as return types (which name wins);
//   * a THREE-deep typedef chain and a chain that crosses a keyword base;
//   * the return name ASSIGNED, READ and SELECTED inside the body;
//   * a class-handle alias, a queue alias and an event alias;
//   * a typedef whose base is a CLASS-SCOPE name (`Cls::inner`).

package zed9;
  typedef enum bit [1:0] { Z_K, Z_L, Z_M } RawMode;
  typedef RawMode  ModeA;            // first alias of the SAME enum
  typedef RawMode  modeB;            // second alias of the same enum, lower case
  typedef ModeA    ModeChain2;       // depth 2
  typedef ModeChain2 MODE_CHAIN3;    // depth 3

  typedef struct packed { logic [3:0] hi, lo; } RecRaw;
  typedef RecRaw   RecVia;
  typedef union packed { logic [7:0] w; logic [7:0] x; } BagRaw;
  typedef BagRaw   BagVia;
  typedef logic [15:0] WordRaw;
  typedef WordRaw  WordVia;
  typedef string   TextRaw;          // keyword base
  typedef TextRaw  TextVia;          // named base over a keyword base
  typedef real     FloatRaw;
  typedef FloatRaw FloatVia;
  typedef bit      FlagRaw;
  typedef FlagRaw  FlagVia;
  typedef int unsigned CountRaw;
  typedef CountRaw CountVia;
  typedef byte     ByteQ [$];        // a QUEUE typedef (keyword base + dims)
  typedef ByteQ    ByteQVia;         // an alias of a queue typedef
  typedef event    EvRaw;
  typedef EvRaw    EvVia;

  class Cage9;
    typedef enum { CG_U, CG_V } Inner;
    typedef Inner InnerVia;
    function Inner    cgDirect(); return CG_U; endfunction
    function InnerVia cgVia();    return CG_V; endfunction
  endclass
  typedef Cage9        CageHandle;   // a CLASS-HANDLE alias of a name
  typedef CageHandle   CageHandle2;
  typedef Cage9::Inner ScopedInnerVia; // base spelled with a CLASS SCOPE

  // Two typedefs of ONE enum, both returned.
  function ModeA zModeA(); return Z_K; endfunction
  function modeB zModeB(); return Z_L; endfunction
  function RawMode zRaw();  return Z_M; endfunction
  function ModeChain2  zChain2(); return Z_K; endfunction
  function MODE_CHAIN3 zChain3(); return Z_L; endfunction

  function RecVia   zRec();   zRec = '0; endfunction
  function BagVia   zBag();   zBag = '0; endfunction
  function WordVia  zWord();  zWord = 16'h1234; endfunction
  function TextVia  zText();  zText = "q"; endfunction
  function FloatVia zFloat(); zFloat = 1.5; endfunction
  function FlagVia  zFlag();  zFlag = 1'b1; endfunction
  function CountVia zCount(); zCount = 3; endfunction
  function ByteQVia zQueue(); zQueue = '{8'd1}; endfunction
  function CageHandle  zCage();  zCage = null; endfunction
  function CageHandle2 zCage2(); zCage2 = null; endfunction
  function ScopedInnerVia zScopedInner(); return Cage9::CG_U; endfunction

  // THE RETURN NAME, THREE WAYS, all on an alias-of-a-name return type.
  function ModeA zAssigned();          // assigned only
    zAssigned = Z_K;
  endfunction
  function ModeA zReadBack();          // assigned then READ
    zReadBack = Z_L;
    if (zReadBack == Z_L) zReadBack = Z_M;
  endfunction
  function WordVia zSelected();        // assigned then bit-SELECTED
    zSelected = 16'h00ff;
    zSelected[3] = 1'b0;
    if (zSelected[2:1] == 2'b11) zSelected = 16'h0;
  endfunction
endpackage

module Rig9;
  import zed9::*;
  initial $display(zModeA(), zModeB(), zRaw(), zChain2(), zChain3(), zRec(),
                   zBag(), zWord(), zText(), zFloat(), zFlag(), zCount(),
                   zAssigned(), zReadBack(), zSelected(), zScopedInner());
endmodule
