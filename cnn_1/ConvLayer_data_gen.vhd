library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ConvLayer_data_gen is
  generic (
           BP            : string := "no";  --"no"/"yes"  -- Bypass
  	       mult_sum      : string := "sum";           
           N             : integer := 8; -- input data width
      --     M             : integer := 8; -- input weight width
      --     W             : integer := 8; -- output data width      (Note, W+SR <= N+M+4)
      --     SR            : integer := 2; -- data shift right before output
           --bpp           : integer := 8; -- bit per pixel
  	       in_row        : integer := 256;
  	       in_col        : integer := 256
  	       );
  port    (
           clk         : in std_logic;
           rst         : in std_logic;
  	       d_in        : in std_logic_vector (N-1 downto 0);
  	       en_in       : in std_logic;
  	       sof_in      : in std_logic; -- start of frame

           data2conv1  : out std_logic_vector (N-1 downto 0);
           data2conv2  : out std_logic_vector (N-1 downto 0);
           data2conv3  : out std_logic_vector (N-1 downto 0);
           data2conv4  : out std_logic_vector (N-1 downto 0);
           data2conv5  : out std_logic_vector (N-1 downto 0);
           data2conv6  : out std_logic_vector (N-1 downto 0);
           data2conv7  : out std_logic_vector (N-1 downto 0);
           data2conv8  : out std_logic_vector (N-1 downto 0);
           data2conv9  : out std_logic_vector (N-1 downto 0);

           en_out      : out std_logic;
           sof_out     : out std_logic);
end ConvLayer_data_gen;

architecture a of ConvLayer_data_gen is

constant EN_BIT  : integer range 0 to 1 := 0;
constant SOF_BIT : integer range 0 to 1 := 1;
constant PIX_FST : integer range 0 to 7 := 0;
constant LIN_FST : integer range 0 to 7 := 1; 
constant PIX_LST : integer range 0 to 7 := 2;
constant LIN_LST : integer range 0 to 7 := 3;
constant PIX_SOF : integer range 0 to 7 := 4;

signal d_in1,   d_in2,   d_in3   : std_logic_vector (N-1 downto 0);
signal d_mid1,  d_mid2,  d_mid3  : std_logic_vector (N-1 downto 0);
signal d_end1,  d_end2,  d_end3  : std_logic_vector (N-1 downto 0);
signal en_in1,  en_in2,  en_in3  : std_logic_vector(1 downto 0);
signal en_mid1, en_mid2, en_mid3 : std_logic_vector(1 downto 0);
signal en_end1, en_end2, en_end3 : std_logic_vector(1 downto 0);
signal firstlast_1, firstlast_2, firstlast_3, firstlast_mid, firstlast_mid2 : std_logic_vector (4 downto 0);

--signal en_in1v,  en_in2v,  en_in3v  : std_logic_vector (N-1 downto 0);
--signal en_mid1v, en_mid2v, en_mid3v : std_logic_vector (N-1 downto 0);
--signal en_end1v, en_end2v, en_end3v : std_logic_vector (N-1 downto 0);

--constant fifo_depth : integer := in_col * N / bpp - 3;
constant fifo_depth : integer := in_col  - 3;
type t_Memory is array (0 to fifo_depth) of std_logic_vector(N-1 downto 0);
signal mem_line1 : t_Memory;
signal mem_line2 : t_Memory;


type t_datacontrol is array (0 to fifo_depth) of std_logic_vector(1 downto 0);
signal en_line1 : t_datacontrol;
signal en_line2 : t_datacontrol;

type t_firstlast_pxl is array (0 to fifo_depth) of std_logic_vector(4 downto 0);
signal firstlast_pxl : t_firstlast_pxl;

--signal head : std_logic_vector 
signal Head : natural range 0 to fifo_depth ;
signal Tail : natural range 0 to fifo_depth ;

signal row_num           : natural range 0 to in_row;
signal col_num           : natural range 0 to in_col;
signal start_pixel_count : natural range 0 to in_col + 2;
--signal start_sof_count   : natural range 0 to in_col + 1;
signal start_pixel_done  : std_logic;
signal start_sof_done    : std_logic;
--signal start_sof_count_en: std_logic;

signal line_first  ,line_first_d  : std_logic;
signal line_last   ,line_last_d   : std_logic;
signal pixel_first ,pixel_first_d : std_logic;
signal pixel_last  ,pixel_last_d  : std_logic;

--signal en2conv     : std_logic_vector(1 downto 0);
--signal en_count    : std_logic_vector(1 downto 0);


begin

gen_no_BP: if BP = "no" generate 

-- 3 input samples

  insamp1 : process (clk)
  begin
    if rising_edge(clk) then
       if en_in = '1' then
          d_in1  <= d_in  ;
          d_in2  <= d_in1 ;
          d_in3  <= d_in2 ;  

          d_mid2 <= d_mid1;
          d_mid3 <= d_mid2;

          d_end2 <= d_end1;
          d_end3 <= d_end2; 
       end if;
    end if;
  end process insamp1;

  insamp2 : process (clk,rst)
  begin
    if rst = '1' then
       en_in1  <= (others => '0');
       en_in2  <= (others => '0');
       en_in3  <= (others => '0');
       en_mid2 <= (others => '0');
       en_mid3 <= (others => '0');
       en_end2 <= (others => '0');
       en_end3 <= (others => '0');
       firstlast_1    <= (others => '0');
       firstlast_2    <= (others => '0');
       firstlast_3    <= (others => '0');
       firstlast_mid2 <= (others => '0');

    elsif rising_edge(clk) then
       if en_in = '1' then
          en_in1(EN_BIT)  <= en_in;
          en_in1(SOF_BIT) <= sof_in;
          en_in2  <= en_in1;
          en_in3  <= en_in2;


          firstlast_1(PIX_FST) <= pixel_first;
          firstlast_1(LIN_FST) <= line_first; 
          firstlast_1(PIX_LST) <= pixel_last;
          firstlast_1(LIN_LST) <= line_last;
          firstlast_1(PIX_SOF) <= sof_in;
          firstlast_2 <= firstlast_1;
          firstlast_3 <= firstlast_2;

          en_mid2 <= en_mid1;
          en_mid3 <= en_mid2;
          firstlast_mid2 <= firstlast_mid;

          en_end2 <= en_end1;
          --en_end3 <= en_end2;
          en_end3 <= en_end2;
       end if;
    end if;
  end process insamp2;

-- 2 lines

  fifo1 : process (clk)
  begin
    if rising_edge(clk) then
       if en_in = '1' then
          mem_line1(tail)      <= d_in3      ;
          mem_line2(tail)      <= d_mid3     ;
          firstlast_pxl(tail)  <= firstlast_3;
          d_mid1         <= mem_line1(head)    ;
          d_end1         <= mem_line2(head)    ;
          firstlast_mid  <= firstlast_pxl(head);
       end if;
    end if;
  end process fifo1;

  en_shr1 : process (clk,rst)
  begin
    if rst = '1' then
       en_line1 <= (others => (others => '0'));
       en_line2 <= (others => (others => '0'));
       en_mid1  <= (others => '0');
       en_end1  <= (others => '0');
    elsif rising_edge(clk) then
       if en_in = '1' then
          en_line1(tail) <= en_in3;
          en_line2(tail) <= en_mid3;
          en_mid1 <= en_line1(head);
          en_end1 <= en_line2(head);
       end if;
    end if;
  end process en_shr1;


-- fifo control
  fifo_ctr : process (clk,rst)
  begin
    if rst = '1' then
       head <= 0;
       tail <= fifo_depth;
    elsif rising_edge(clk) then
       if en_in = '1' then
          if head =  fifo_depth then
             head <= 0;
          else
             head <= head + 1;
          end if;
          if tail =  fifo_depth then
             tail <= 0;
          else
             tail <= tail + 1;
          end if;
       end if;
    end if;
  end process fifo_ctr;

---- row/column counter
--  rc_cnt : process (clk,rst)
--  begin
--    if rst = '1' then
--       row_num  <= 0;
--       col_num  <= 0;
--    elsif rising_edge(clk) then
--       if en_in = '1' then
--          if sof = '1' then
--             row_num   <= 0;
--             col_num   <= 0;
--          else
--             if col_num =  in_col -1 then
--                col_num <= 0;
--                row_num <= row_num + 1;
--             else
--                col_num <= col_num + 1;
--             end if;
--          end if;
--       end if;
--    end if;
--  end process rc_cnt;

-- convolution padding control
  conv_ctr : process (clk,rst)
  begin
    if rst = '1' then
        row_num   <= 0;
        col_num   <= 0;
        --en_count  <= (others => '0');
        start_pixel_count <=  0 ;
        start_pixel_done  <= '0';
        --start_sof_count   <=  0 ;
        --start_sof_done    <= '0';
    elsif rising_edge(clk) then
       if en_in = '1' then
          --if en_mid1(SOF_BIT) = '1' then
          --   row_num   <= 0;
          --   col_num   <= 0;
          --   --en_count  <= '1';
          --else
             --en_count(EN_BIT)   <= '0';
             if col_num =  in_col -1 then
                col_num <= 0;
                if row_num = in_row - 1 then
                   row_num   <= 0;
                   --start_sof_done <= '1';
                else
                   row_num <= row_num + 1;
                   --start_sof_done <= '0';
                end if;
             else
                col_num <= col_num + 1;
             end if;
          --end if;
          if start_pixel_done = '0' then
             start_pixel_count <= start_pixel_count + 1;
             if start_pixel_count = in_col + 1  then
                start_pixel_done <= '1';
             end if;
          end if;

        --  if row_num  = 0 and col_num   = 0 then
        --    start_sof_count    <=  0;
        --    start_sof_count_en <= '1';
        --    start_sof_done <= '0';
        --  else
        --     if start_sof_count_en = '1' then
        --        start_sof_count <= start_sof_count + 1;
        --        if start_sof_count = in_col then
        --           start_sof_done <= '1';
        --           start_sof_count_en <= '0';
        --        end if;
        --     else
        --        start_sof_done <= '0';
        --     end if;
        --  end if;
        --  if row_num  = 0 and col_num   = 0 then
        --    start_sof_done <= '1';
        --  else
        --    start_sof_done <= '0';
        --  end if;

       else
          --start_sof_done <= '0';
       end if;
       --en_count(EN_BIT)  <= en_in; -- and start_pixel_done;
       --en_count(SOF_BIT) <= start_sof_done ; --en_end3(SOF_BIT);
    end if;
  end process conv_ctr;
start_sof_done <= '1' when row_num  = 0 and col_num   = 0 else '0';

 conv_ctr2 : process (row_num, col_num)
  begin
     if col_num  = 0  then
        pixel_first <= '1';
        pixel_last  <= '0';
     elsif col_num =  in_col - 1 then
        pixel_first <= '0';
        pixel_last  <= '1';
      else
        pixel_first <= '0';
        pixel_last  <= '0';
     end if;

     if row_num = 0  then
        line_first <= '1';
        line_last  <= '0';
     elsif row_num =  in_row - 1 then
        line_first <= '0';
        line_last  <= '1';
      else
        line_first <= '0';
        line_last  <= '0';
     end if;
  end process conv_ctr2;

-- data sampling
--  in line 3->2->1
-- mid line 3->2->1  -- mid_2 - convolution point
-- end line 3->2->1

-- Boundary cases:
-- first line  | last line | 1st pixel | last pixel |  
--   V V V     |  0 0 0    |  V V 0    |  0 V V     |  
--   V V V     |  V V V    |  V V 0    |  0 V V     |  
--   0 0 0     |  V V V    |  V V 0    |  0 V V     |  

-- data conv numbering
--   1 2 3
--   4 5 6
--   7 8 9

  samp_conv : process (clk,rst)
  begin
    if rst = '1' then
       data2conv1 <= (others => '0');
       data2conv2 <= (others => '0');
       data2conv3 <= (others => '0');
       data2conv4 <= (others => '0');
       data2conv5 <= (others => '0');
       data2conv6 <= (others => '0');
       data2conv7 <= (others => '0');
       data2conv8 <= (others => '0');
       data2conv9 <= (others => '0');
       sof_out    <= '0';
       --en2conv    <= (others => '0');      
    elsif rising_edge(clk) then   
       --if line_first = '1' and pixel_first = '1'  then
       if firstlast_mid2(LIN_FST) = '1' and firstlast_mid2(PIX_FST) = '1'  then 

          data2conv9 <= d_in1  ;
          data2conv8 <= d_in2  ;
          data2conv7 <= (others => '0');

          data2conv6 <= d_mid1 ;
          data2conv4 <= (others => '0');

          data2conv3 <= (others => '0');
          data2conv2 <= (others => '0');
          data2conv1 <= (others => '0');

       --elsif line_first = '1' and pixel_last = '1' then
       elsif firstlast_mid2(LIN_FST) = '1' and firstlast_mid2(PIX_LST) = '1' then

          data2conv9 <= (others => '0');
          data2conv8 <= d_in2;
          data2conv7 <= d_in3;

          data2conv6 <= (others => '0');
          data2conv4 <= d_mid3;

          data2conv3 <= (others => '0');
          data2conv2 <= (others => '0');
          data2conv1 <= (others => '0');

       --elsif line_first = '1' then
       elsif firstlast_mid2(LIN_FST) = '1' then

          data2conv9 <= d_in1  ;
          data2conv8 <= d_in2  ;
          data2conv7 <= d_in3  ;

          data2conv6 <= d_mid1 ;
          data2conv4 <= d_mid3 ;

          data2conv3 <= (others => '0');
          data2conv2 <= (others => '0');
          data2conv1 <= (others => '0');

       --elsif line_last = '1' and pixel_first = '1'  then
       elsif firstlast_mid2(LIN_LST) = '1' and firstlast_mid2(PIX_FST) = '1'  then

          data2conv9 <= (others => '0');
          data2conv8 <= (others => '0');
          data2conv7 <= (others => '0');

          data2conv6 <= d_mid1 ;
          data2conv4 <= (others => '0');

          data2conv3 <= d_end1;
          data2conv2 <= d_end2;
          data2conv1 <= (others => '0'); 

       --elsif line_last = '1' and pixel_last = '1' then
       elsif firstlast_mid2(LIN_LST) = '1' and firstlast_mid2(PIX_LST) = '1' then

          data2conv9 <= (others => '0');
          data2conv8 <= (others => '0');
          data2conv7 <= (others => '0'); 

          data2conv6 <= (others => '0');
          data2conv4 <= d_mid3;

          data2conv3 <= (others => '0');
          data2conv2 <= d_end2;
          data2conv1 <= d_end3; 

       --elsif line_last = '1' then
       elsif firstlast_mid2(LIN_LST)  = '1' then
          data2conv9 <= (others => '0');
          data2conv8 <= (others => '0');
          data2conv7 <= (others => '0');

          data2conv6 <= d_mid1 ;
          data2conv4 <= d_mid3 ;

          data2conv3 <= d_end1;
          data2conv2 <= d_end2;
          data2conv1 <= d_end3; 

       --elsif pixel_first = '1' then
       elsif firstlast_mid2(PIX_FST) = '1' then
          data2conv9 <= d_in1  ;
          data2conv8 <= d_in2  ;
          data2conv7 <= (others => '0')  ;

          data2conv6 <= d_mid1 ;
          data2conv4 <= (others => '0');

          data2conv3 <= d_end1;
          data2conv2 <= d_end2;
          data2conv1 <= (others => '0');

       --elsif pixel_last = '1' then
       elsif firstlast_mid2(PIX_LST) = '1' then
          data2conv9 <= (others => '0')  ;
          data2conv8 <= d_in2  ;
          data2conv7 <= d_in3  ;

          data2conv6 <= (others => '0');
          data2conv4 <= d_mid3 ;

          data2conv3 <= (others => '0');
          data2conv2 <= d_end2;
          data2conv1 <= d_end3;

       else
          data2conv9 <= d_in1  ;
          data2conv8 <= d_in2  ;
          data2conv7 <= d_in3  ;
          data2conv6 <= d_mid1 ;
          data2conv4 <= d_mid3 ;
          data2conv3 <= d_end1;
          data2conv2 <= d_end2;
          data2conv1 <= d_end3; 
       end if;
       data2conv5 <= d_mid2 ;
       en_out     <= en_in and start_pixel_done;
       if start_pixel_done = '1' then
          sof_out    <= firstlast_mid2(PIX_SOF);
       else
          sof_out    <= '0';
       end if;
       --en2conv    <= en_count;
    end if;
  end process samp_conv;

end generate; -- BP = yes

gen_BP: if BP = "yes" generate 

           data2conv1  <= d_in  ;
           data2conv2  <= d_in  ;
           data2conv3  <= d_in  ;
           data2conv4  <= d_in  ;
           data2conv5  <= d_in  ;
           data2conv6  <= d_in  ;
           data2conv7  <= d_in  ;
           data2conv8  <= d_in  ;
           data2conv9  <= d_in  ;
           en_out      <= en_in ;
           sof_out     <= sof_in;

end generate;


end a;