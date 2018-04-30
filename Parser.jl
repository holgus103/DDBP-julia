module Parser

const input_count = 208

# first player order : S E N W
# hands order : W N E S
# suits : Spades, Hearts, Diamonds, Clubs

    function read_file(path::String, lines_count::Int, shuffle = false, no_trump = true, trump = true, no_trump_test = true, trump_test = true, split = 0.66)
        # deal dictionary
        deals = Dict()

        train_end = (lines_count * split) |> floor
        # test_outputs_set = []
        line_number = 1
        lines = [];

        # store all lines in memory 
        lines = Array(String, lines_count)
        for line in eachline(file)
            lines[line_number] = line
            line_number += 1
        end

        # shuffle stored lines
        if(shuffle)
            shuffle(lines)
        end

        for line in lines
            if(line_number < train_end)
            else
                process_line!(line, deals, no_trump, trump)
            end
        end     
        close(file)
    end

    function process_line!(line::String, deals::Dict{Int, Array{Float32, 2}}, no_trump::Bool, trump::Bool)
        # dictionary to get results
        dict = Dict{Char, Int}('0' => 0, 
                    '1' => 1, 
                    '2' => 2, 
                    '3' => 3, 
                    '4' => 4, 
                    '5' => 5, 
                    '6' => 6, 
                    '7' => 7, 
                    '8' => 8, 
                    '9' => 9, 
                    'A' => 10, 
                    'B' => 11, 
                    'C' => 12, 
                    'D' => 13,
                    )
        t = split(input, ':');
        vals = split(t[1], ' ');
        # preallocate array
        b = no_trump ? 0 : 1
        e = trump ? 4 : 0
        # process results

        res = map(x-> get(dict, x, 0), collect(t[2][((b*4) + 1):e*4])) 
        # process hands
        count = 1;
        hands = [process_hand(vals[1]), process_hand(vals[2]), process_hand(vals[3]), process_hand(vals[4])]
        for suit in in b:e
            for vist in (0,2)
                tmp_hands = copy(hands);
                if(suit > 1)
                    for i in 1:4
                        spades = tmp_hands[i][1:13]
                        tmp_hands[i][1:13] = tmp_hands[i][13*(suit - 1)+1:suit*13]
                        tmp_hands[i][13*(suit - 1)+1:suit*13] = spades
                    end
                end
                current = vcat(tmp_hands[(4-vist)+1:(len(deals))],tmp_hands[1:(4-vist)]);
                sample = collect(Iterators.flatten(current))
                push!(dict[res[1]], sample);
            end
        end

    end

    function process_hand(hand::String)
        dict = Dict{Char,Int}(
            'A' => 0,
            'K' => 1,
            'Q' => 2,
            'J' => 3,
            'T' => 4,
            '9' => 5,
            '8' => 6,
            '7' => 7,
            '6' => 8,
            '6' => 8,
            '5' => 9,
            '4' => 10,
            '3' => 11,
            '2' => 12,
        )

        colors = split(hand, '.');
        hand = Array{Float32}(54);
        for i in 1:4
            color = colors[i]
            for c in collect(color)
                # get corresponding array index
                n = get(dict, c, 0)
                # shift by color
                index = (i-1) + n
                # mark card's presence
                hand[index] = 1.0
            end
            
        end

        return hand;
    end

end

