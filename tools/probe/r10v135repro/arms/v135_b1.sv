// r10v135 (VERIFIER) ARM b1 — INDEX-TYPE FACES the implementer's a1 did NOT
// spell.  ONE home (an out-of-body method of a package class, a body local:
// the PROMOTED shape) and one position; only the SPELLING varies.  Cells are
// deliberately out of kind order and every cell carries its own unique name.
package pkgFaceQuebec1;
  class nestOuterWhisky1;
    class nestInnerXray1;
      int niv;
    endclass
    int nov;
  endclass
endpackage

package pkgFaceZulu1;
  import pkgFaceQuebec1::*;

  interface class ifcAlfa1;
    pure virtual function int gv();
  endclass

  typedef struct packed { bit [3:0] sa; bit [3:0] sb; } stTangoPk1;
  typedef struct { int ua; byte ub; } stUniformUp1;
  typedef union packed { bit [7:0] va; bit [7:0] vb; } unVictor1;

  class parmYankee1 #(type PKW1 = int);
    int pv;
  endclass
  typedef parmYankee1 #(byte) tdSpecSierra1;

  class plainDelta1;
    int dv;
  endclass
  typedef plainDelta1 tdChain1Echo1;
  typedef tdChain1Echo1 tdChain2Foxtrot1;

  virtual class absGolf1;
    pure virtual function int av();
  endclass

  class hostHotel1;
    extern function void facesIndia1();
  endclass

  function void hostHotel1::facesIndia1();
    bit f07UnionTd1 [unVictor1];                 // 07 a packed-UNION typedef
    bit f02StructPk1[stTangoPk1];                // 02 a packed-STRUCT typedef
    bit f05Abstract1[absGolf1];                  // 05 a VIRTUAL (abstract) class name
    bit f01IfcCls1  [ifcAlfa1];                  // 01 an INTERFACE CLASS name
    bit f04SpecTd1  [tdSpecSierra1];             // 04 a TYPEDEF of a specialization
    bit f06Chain2Td1[tdChain2Foxtrot1];          // 06 a TYPEDEF of a TYPEDEF of a class
    bit f03StructUp1[stUniformUp1];              // 03 an UNPACKED-STRUCT typedef
    bit f08NestScope1[nestOuterWhisky1];         // 08 an IMPORTED class name
    f07UnionTd1.delete();
    f02StructPk1.delete();
    f05Abstract1.delete();
    f01IfcCls1.delete();
    f04SpecTd1.delete();
    f06Chain2Td1.delete();
    f03StructUp1.delete();
    f08NestScope1.delete();
  endfunction
endpackage

module topFaceJuliett1;
  import pkgFaceZulu1::*;
  hostHotel1 hKiloFace1;
  initial begin
    hKiloFace1 = new();
    hKiloFace1.facesIndia1();
  end
endmodule
