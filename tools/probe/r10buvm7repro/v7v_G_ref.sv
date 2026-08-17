// vbuvm7 adversarial arm G — ref args, automatic locals, inherited props, this/super.
typedef struct { int used; } stG_t;
class baseG;
  stG_t barr[4];
  function void fb(); barr[0].used++; endfunction
endclass
class derG extends baseG;
  stG_t darr[4];
  function void fd();
    barr[1].used++;             // G1 INHERITED property, implicit this
    this.darr[1].used++;        // G2 explicit this  (golden: BAD_SYMBOL, R3)
    super.barr[2].used++;       // G3 super-qualified
    darr[2].used++;             // G4 own property (control)
  endfunction
endclass
module topG;
  stG_t garr[4];
  task automatic tref(ref stG_t r[4]);
    r[1].used++;                // G5 through a REF formal
  endtask
  function automatic void floc();
    stG_t lo[4];
    lo[1].used++;               // G6 AUTOMATIC LOCAL variable
  endfunction
  initial begin
    tref(garr);
    floc();
    garr[3].used++;             // G7 control
  end
endmodule
