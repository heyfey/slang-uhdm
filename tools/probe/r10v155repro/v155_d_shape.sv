// r10v155 arm D — DECLARATOR SHAPES, INSTANCE COUNTS and TYPE PARAMETERS.
// MEASUREMENT ONLY.
package pkgD155v;
  class GenD155v #(parameter type T = int, parameter int W = 4);
    T g;
  endclass
endpackage

// D1: 1, 2, 3 declarators, with and without initialisers, packed dims at the
// use, and a use three `begin`s deep.
module mShapeD155v;
  initial begin
    typedef bit [7:0] shD155v;
    shD155v          one155v;
    shD155v          two155vA, two155vB;
    shD155v          three155vA, three155vB, three155vC;
    shD155v          init155v = 8'd1;
    shD155v          initTwo155vA = 8'd2, initTwo155vB = 8'd3;
    shD155v [1:0]    packedAtUse155v;
    begin
      begin
        begin
          shD155v deep155v;
          deep155v = 8'd4;
        end
      end
    end
    one155v = 8'd5;
  end
endmodule

// D2: a TYPE PARAMETER named the same as a statement-scope typedef, with and
// without an override.
module mTpD155v #(parameter type tpD155v = int);
  initial begin
    typedef byte tpD155v;             // shadows the module's TYPE PARAMETER
    tpD155v tpValD155v;               // ?  must NOT degrade: golden resolves
    tpValD155v = 8'd6;
  end
endmodule

module mTpUserD155v;
  mTpD155v         u1D155v();                 // default
  mTpD155v #(.tpD155v(shortint)) u2D155v();   // overridden
  mTpD155v #(.tpD155v(logic [5:0])) u3D155v();// overridden again
endmodule

// D3: THREE INSTANCES of the same module, each carrying the same statement
// scope typedef — three elaborated copies of one degrade.
module mTriD155v;
  initial begin
    typedef bit [3:0] triD155v;
    triD155v triValD155v;             // ?
    triValD155v = 4'd7;
  end
  function automatic int fTriD155v();
    typedef int triFuncD155v;
    triFuncD155v triFuncValD155v;     // ?
    triFuncValD155v = 8;
    return triFuncValD155v;
  endfunction
endmodule

module mTriTopD155v;
  mTriD155v i1D155v();
  mTriD155v i2D155v();
  mTriD155v i3D155v();
endmodule

// D4: a parameterised CLASS name shadowed by a statement-scope typedef.
module mGenClsD155v;
  import pkgD155v::GenD155v;
  initial begin
    typedef int GenD155v;             // shadows the imported generic class
    GenD155v genValD155v;             // ?
    genValD155v = 9;
  end
endmodule

// D5: `$unit` typedef shadowed by a statement-scope typedef of the same name,
// and a $unit typedef used unshadowed (control).
typedef bit [6:0] unitD155v;
typedef bit [2:0] unitCtlD155v;
module mUnitD155v;
  unitCtlD155v unitCtlValD155v;       // control: resolves
  initial begin
    typedef byte unitD155v;           // shadows the $unit typedef
    unitD155v unitValD155v;           // ?
    unitValD155v = 8'd10;
  end
endmodule
