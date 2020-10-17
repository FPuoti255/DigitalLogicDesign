library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity project_reti_logiche is
    port (
    i_clk : in std_logic;
    i_start : in std_logic;
    i_rst : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector (15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;


architecture FSM of project_reti_logiche is

    type state_type is (s_rst, s_arrivaDato, s_elab, s_done);
    signal current_state, next_state : state_type;
    signal tmp_cod, next_tmpcod: unsigned (7 downto 0); 
    signal tmp_check, next_tmpcheck : unsigned (7 downto 0);   
    signal tmp_addr, next_tmpaddr: std_logic_vector (2 downto 0);
    signal codArrivato, next_codArrivato: boolean := false;   
    
    
    begin
        state_reg: process (i_clk, i_rst)
        begin
            if i_rst='1' then
                current_state <= s_rst;
                tmp_cod <= (others => '0');
                tmp_addr <= (others => '0');
                codArrivato <= false;

            elsif rising_edge(i_clk) then
                current_state <= next_state;
                tmp_cod <= next_tmpcod;
                tmp_check <= next_tmpcheck;
                tmp_addr <= next_tmpaddr;
                codArrivato <= next_codArrivato;
            end if;
        end process;

        deltaProcess : process (current_state, codArrivato, i_start, tmp_check, tmp_addr)
            begin
                case current_state is

                    when s_rst =>
                        if (i_start = '1') then
                            next_state <= s_arrivaDato;
                        else next_state <= current_state;
                        end if ;               

                    when s_arrivaDato =>
                        if(codArrivato) then
                            next_state <= s_elab;
                        else
                            next_state <= s_arrivaDato; 
                        end if; 
                                     

                    when s_elab =>
                    if (tmp_check < to_unsigned(4, 8)) then
                        next_state <= s_done;

                    elsif(unsigned (tmp_addr) = to_unsigned(7, 3)) then
                            next_state <= s_done;
                    else
                        next_state <= s_arrivaDato;
                    end if;


                    when s_done =>
                        if (i_start = '1') then
                            next_state <= current_state;
                        else 
                            next_state <= s_rst;
                        end if; 
                end case;
            end process;

        lambdaProcess: process (current_state, i_start, i_data, codArrivato, tmp_cod, tmp_check, tmp_addr)
        begin

            next_tmpcod <= tmp_cod;
            next_tmpcheck <= tmp_check;
            next_tmpaddr <= tmp_addr;
            next_codArrivato <= codArrivato;

            o_address <= (others => '-');
            o_data <= (others => '-');
            o_en <= '0';
            o_we <= '-';
            o_done <= '0';

            case current_state is

                when s_rst =>
                    if (i_start = '1') then
                        o_address <= (3 => '1', others => '0');
                        o_en <= '1';
                        o_we <= '0';
                    end if ;     

                when s_arrivaDato =>
                    if(codArrivato) then
                        next_tmpcheck <= (tmp_cod - unsigned(i_data));
                    else
                        next_codArrivato <= true;
                        next_tmpcod <= unsigned(i_data);
                        next_tmpaddr <= std_logic_vector(to_unsigned(0, 3));
                        o_address <= std_logic_vector(to_unsigned(0, 16));
                        o_en <= '1';
                        o_we <= '0';
                    end if;                    


                when s_elab =>
                    if (tmp_check < to_unsigned(4, 8)) then
                        o_address <= (3 => '1', 0 => '1' , others => '0');
                        o_data <=  '1' & tmp_addr & std_logic_vector(shift_left(to_unsigned(1, 4), to_integer(tmp_check)));
                        o_en <='1';
                        o_we <='1';
                    elsif (unsigned (tmp_addr) = to_unsigned(7, 16)) then
                        o_address <= ( 3 => '1' , 0 => '1' , others => '0');
                        o_data <= std_logic_vector(tmp_cod);
                        o_en <='1';
                        o_we <='1';                        
                    else
                        next_tmpaddr <= std_logic_vector (unsigned(tmp_addr) + to_unsigned(1,3));
                        o_address  <= std_logic_vector(to_unsigned(0,13)) & std_logic_vector (unsigned(tmp_addr) + to_unsigned(1,3));
                        o_en <= '1';
                        o_we <= '0';
                    end if;


                when s_done =>
                    if (i_start = '1') then
                        o_done <= '1';
                        o_en <= '0';
                        o_we <= '0';
                    else                
                        o_done <= '0';
                        next_tmpcod <= (others => '0');                   
                        next_tmpaddr <= (others =>'0'); 
                        next_codArrivato <= false;
                    end if;
            end case;
        end process;        
    end FSM;