class 'Walking'

function Walking:__init()
    Events:Subscribe( "InputPoll", self, self.InputPoll )
end

function Walking:InputPoll()
    if Input:GetValue( Action.StuntJump ) == 0 then
        Input:SetValue(Action.Walk, 0)
    else
        Input:SetValue(Action.Walk, 1)
    end
end

walking = Walking()