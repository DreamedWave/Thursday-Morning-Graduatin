function start(song) -- do nothing

end

function update(elapsed)
    if difficulty == 2 and curStep > 1104 then
        local currentBeat = (songPos / 1000)*(bpm/60)
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0.15) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*0.15) * math.pi), i)
		end
    end
end

function beatHit(beat) -- do nothing

end

function stepHit(step) -- do nothing

end