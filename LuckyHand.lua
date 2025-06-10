if not LuckyHand then
	LuckyHand = {}
end

local mod_path = "" .. SMODS.current_mod.path
LuckyHand.path = mod_path
LuckyHand_config = SMODS.current_mod.config

---- ATLAS STUFF ----
SMODS.Atlas {
	key = "RareJokers",
	px = 71,
	py = 95,
	path = "atlasrare.png"
}

SMODS.Atlas {
	key = "UncommonJ",
	px = 71,
	py = 95,
	path = "atlasuncom.png"
}

SMODS.Atlas {
	key = "Decks",
	px = 71,
	py = 95,
	path = "decks.png"
}

---- JOKERS ----
local jokers = {
	pairseats = {
		key = "pairseats",
		loc_txt = {
			name = "Pair Seats",
			text = {
				'If played hand is a {E:1, C:attention}Pair{}',
				'retrigger all scoring',
				'cards {C:attention}#1#{} additional times'
			},
			
			unlock = {
				"Win a run with",
				"your final hand being",
				"a {C:attention}Pair{}",
			}
		},
		
		unlocked = false,
		discovered = false,
		eternal = true,
		blueprint = true,
		perishable = true,
		
		config = {extra = {retriggers = 2}},
		vars = {{retriggers = 2}},
		pos = {x = 0, y = 0},
		rarity = 3,
		cost = 10,
			
		calculate = function(self, card, context)
			if self.debuff then return nil end
			if G.GAME.current_round.current_hand.handname == "Pair" then
				if context.cardarea == G.play then
					return {
						repetitions = card.ability.extra.retriggers,
						card = card,
					}
				end
			end
		end,
		
		check_for_unlock = function(self, args)
			if args.type == "win" and G.GAME.last_hand_played == "Pair" then
				return true
			end
		end
	},
	
	--[[luckyseven = {
		key = "luckyseven",
		loc_txt = {
			name = "Lucky Seven",
			text = {
				'When a {C:attention}7{} is scored',
				'gain {C:attention}#1#${}'
			}
		},
		
		unlocked = true,
		discovered = false,
		eternal = true,
		blueprint = true,
		perishable = true,
		
		config = {extra = {money = 2}},
		vars = {{money = 2}},
		pos = {x = 0, y = 0},
		rarity = 2,
		cost = 7,
			
		calculate = function(self, card, context)
			if context.individual and context.cardarea == G.play then
				if context.other_card:get_id() == 7 then
					local value = card.ability.extra.money
					
					ease_dollars(value)
					return {
						message = value .."$",
						colour = G.C.MONEY
					}
				end
			end
		end
	},]]
}

---- DECKS ----
-- i was too lazy to make a whole another autoregister
SMODS.Back {
	key = "soulless",
	
	loc_txt = {
		name = "Soulless Deck",
		
		text = {
			'Start with {C:attention}3{} Eternal {C:legendary}Perkeos{}',
			'{C:red}-1{} Consumable slots,',
			'{C:red}-2{} Joker slots'
		},
		
		unlock = {
			"Win a run on {C:gold}Gold{} Stake",
			"without ever having more",
			"than {C:attention}4{} Jokers"
		}
	},
	
	atlas = 'Decks',
	config = {joker_slot = -2, consumable_slot = -1},
	pos = {x = 0, y = 0},
	unlocked = false,
	discovered = false,
	
	apply = function(self)
		G.E_MANAGER:add_event(Event({
			func = function()
				if G.jokers then
					local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_perkeo")
					card:set_eternal(true)
					card.sell_cost = 0
					card:add_to_deck()
					card:start_materialize()
					G.jokers:emplace(card)
					
					local card2 = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_perkeo")
					card2.sell_cost = 0
					card2:set_eternal(true)
					card2:add_to_deck()
					card2:start_materialize()
					G.jokers:emplace(card2)
					
					local card3 = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_perkeo")
					card3.sell_cost = 0
					card3:set_eternal(true)
					card3:add_to_deck()
					card3:start_materialize()
					G.jokers:emplace(card3)
					
					return true
				end
			end,
		}))
	end,
	
	check_for_unlock = function(self, args)
		if args.type == "win_deck" then
			if get_deck_win_stake() >= 8 and G.GAME.max_jokers <= 1 then
				unlock_card(self)
			end
		end
	end	
}


---- FUNCTIONS 2----
local function create_joker(joker)
    if joker.rarity == 3 then
        atlas = 'RareJokers'
    elseif joker.rarity == 2 then
        atlas = 'UncommonJ'
    end

    if joker.vars == nil then joker.vars = {} end

    joker.config = {extra = {}}

    for _, kv_pair in ipairs(joker.vars) do
        local k, v = next(kv_pair)
        joker.config.extra[k] = v
    end

    -- Joker creation

    SMODS.Joker {
        name = joker.name,
        key = joker.key,

        atlas = atlas,
        pos = joker.pos,

        rarity = joker.rarity,
        cost = joker.cost,

        unlocked = joker.unlocked,
        check_for_unlock = joker.check_for_unlock,
        unlock_condition = joker.unlock_condition,
        discovered = joker.discovered,

        blueprint_compat = joker.blueprint,
        eternal_compat = joker.eternal,
        perishable_compat = joker.perishable,

        loc_txt = joker.loc_txt,

        config = joker.config,
        loc_vars = function(self, info_queue, card)
            local vars = {}
            
            for _, kv_pair in ipairs(joker.vars) do
                local k, v = next(kv_pair)
                table.insert(vars, card.ability.extra[k] or v)
            end
            
            return {vars = vars}
        end,

        calculate = joker.calculate,
        update = joker.update,
	}
end

for k, v in pairs(jokers) do
	create_joker(v)
end