// vbuvm5 ADVERSARIAL arm v5 -- DEPTH CONTROLS for the three windows arm v3/v4
// found missing (case ITEM expression, immediate assertion condition, event
// control), plus the neighbouring shapes that must NOT become windows.
//
// A window is only a window if the SAME-DEPTH cell binds AND the ONE-DEEPER
// cell stays bare.  Every window below is measured both ways here.
package qz;

  class boxz #(type Tz = int);
    Tz vz;
  endclass
  typedef boxz #(int) biz_t;

  class ownz;
    typedef logic [7:0] bz_t;
    protected int numsz[$];
    event ez;

    extern task         z01z(int nz);
    extern task         z02z(int nz);
    extern task         z03z(int nz);
    extern task         z04z(int nz);
    extern function void z05z(int nz);
    extern function void z06z(int nz);
    extern function void z07z(int nz);
    extern function void z08z(int nz);
    extern function void z09z(int nz);
    extern task         z10z(int nz);
  endclass

  // z01 -- EVENT CONTROL, decl at d0, read at d0
  task ownz::z01z(int nz);
    bz_t vz;
    @(vz) numsz.push_back(1);
  endtask

  // z02 -- EVENT CONTROL one control body DEEPER than the decl
  task ownz::z02z(int nz);
    bz_t vz;
    if (nz == 0) begin
      @(vz) numsz.push_back(1);
    end
  endtask

  // z03 -- EVENT CONTROL whose decl is in that same block (d1 == d1)
  task ownz::z03z(int nz);
    if (nz == 0) begin
      bz_t vz;
      @(vz) numsz.push_back(1);
    end
  endtask

  // z04 -- an edge event control, decl at d0
  task ownz::z04z(int nz);
    bz_t vz;
    @(posedge vz) numsz.push_back(1);
  endtask

  // z05 -- CASE ITEM expression TWO control bodies deeper than the decl
  function void ownz::z05z(int nz);
    biz_t vz;
    biz_t uz;
    if (nz == 0) begin
      if (nz == 1) begin
        case (vz)
          uz: numsz.push_back(1);
          default: numsz.push_back(2);
        endcase
      end
    end
  endfunction

  // z06 -- ASSERT condition inside a LOOP body (d1)
  function void ownz::z06z(int nz);
    biz_t vz;
    for (int iz = 0; iz < 2; iz++) begin
      assert (vz != null) numsz.push_back(1);
    end
  endfunction

  // z07 -- ASSERT ACTION BLOCK: does the action block raise the depth?
  function void ownz::z07z(int nz);
    biz_t vz;
    biz_t uz;
    assert (vz != null) numsz.push_back(uz == null);
  endfunction

  // z08 -- the ref_var in an assert's ELSE action block
  function void ownz::z08z(int nz);
    biz_t vz;
    biz_t uz;
    assert (vz != null) numsz.push_back(1);
    else numsz.push_back(uz == null);
  endfunction

  // z09 -- CASE ITEM expression that is ALSO the case condition's variable,
  // with the whole case one deeper (control for w05)
  function void ownz::z09z(int nz);
    biz_t vz;
    case (nz)
      0: begin
           biz_t wz;
           case (wz)                    // d1
             wz: numsz.push_back(1);    // decl d1, read d1
             default: numsz.push_back(2);
           endcase
         end
      default: numsz.push_back(3);
    endcase
  endfunction

  // z10 -- an EVENT TRIGGER `->` naming a ref_var-typed local is illegal, so
  // instead: a DELAY control followed by a same-depth call arg (control that a
  // Timed statement does not itself raise the depth)
  task ownz::z10z(int nz);
    bz_t vz;
    #1 numsz.push_back(vz == 0);
  endtask

endpackage
