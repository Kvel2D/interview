import Main.GameRoute;
import haxegon.Math.MathUtils;
import haxegon.*;

typedef MoodBall = {
x: Float,
y: Float,
xOriginal: Float,
yOriginal: Float,
dx: Float,
dy: Float,
repelSpeed: Float,
returnSpeed: Float,
repelRadius: Float,
radius: Float,
color: Int,
mood: String
}

enum GameState {
    Question;
    GoodQuestion;
    LongQuestion;
    Answer;
    Result;
}

enum GameRoute {
    Common;
    Anger;
    Boredoom;
    Depression;
    Fine;
}

class Main {
    var state = GameState.Question;
    var stateTimer = 0.0;
    var route = GameRoute.Common;
    var timeStep = 1 / 60.0;
    var angryBall: MoodBall;
    var fineBall: MoodBall;
    var balls = new Array<MoodBall>();
    var selectedBall: MoodBall;

    function new() {
        Text.align(Text.CENTER);
        for (i in 0...6) {
            var ball = {
                x: Gfx.screenWidthMid + Math.cos(2 * Math.PI * i / 6) * 200,
                y: Gfx.screenHeightMid + Math.sin(2 * Math.PI * i / 6) * 200,
                xOriginal: Gfx.screenWidthMid + Math.cos(2 * Math.PI * i / 6) * 200,
                yOriginal: Gfx.screenHeightMid + Math.sin(2 * Math.PI * i / 6) * 200,
                dx: 0.0,
                dy: 0.0,
                repelSpeed: 10.0,
                returnSpeed: 10.0,
                repelRadius: 150.0,
                radius: 40.0,
                color: Col.WHITE,
                mood: ""};
            balls.push(ball);
        }
        angryBall = balls[0];
        balls[0].color = Col.RED;
        balls[0].mood = "angry";
        balls[1].color = Col.YELLOW;
        balls[1].mood = "happy";
        balls[2].color = Col.BLUE;
        balls[2].mood = "sad";
        balls[3].color = Col.DARKBLUE;
        balls[3].mood = "depressed";
        fineBall = balls[4];
        balls[4].color = Col.GREEN;
        balls[4].mood = "fine";
        balls[5].color = Col.GRAY;
        balls[5].mood = "bored";
    }

    function switchState(newState: GameState) {
        stateTimer = 0;
        state = newState;
    }

    function resetBalls() {
        for (ball in balls) {
            ball.x = ball.xOriginal;
            ball.y = ball.yOriginal;
        }
    }

    function drawBalls() {
        if (route == GameRoute.Fine) {
            for (ball in balls) {
                Gfx.fillCircle(ball.x, ball.y, ball.radius, fineBall.color);
                Text.display(ball.x, ball.y - 20, fineBall.mood, Col.WHITE);
            }
        } else {
            for (ball in balls) {
                Gfx.fillCircle(ball.x, ball.y, ball.radius, ball.color);
                Text.display(ball.x, ball.y - 20, ball.mood, Col.WHITE);
            }
        }
    }

    function updateQuestion() {
        if (stateTimer < 1) {
            if (Mouse.leftclick()) {
                stateTimer = 1;
            }
            Text.display(Gfx.screenWidthMid, Gfx.screenHeightMid, "Now", Col.WHITE);
        } else if (stateTimer < 1 + 2) {
            if (Mouse.leftclick()) {
                stateTimer = 3;
            }
            Text.display(Gfx.screenWidthMid, Gfx.screenHeightMid, "How do you feel?", Col.WHITE);
        } else {
            switchState(GameState.Answer);
        }
    }

    function updateGoodQuestion() {
        if (stateTimer < 1) {
            if (Mouse.leftclick()) {
                stateTimer = 1;
            }
            Text.display(Gfx.screenWidthMid, Gfx.screenHeightMid, "Good", Col.WHITE);
        } else if (stateTimer < 1 + 1) {
            if (Mouse.leftclick()) {
                stateTimer = 2;
            }
            Text.display(Gfx.screenWidthMid, Gfx.screenHeightMid, "Now", Col.WHITE);
        } else if (stateTimer < 1 + 1 + 2) {
            if (Mouse.leftclick()) {
                stateTimer = 4;
            }
            Text.display(Gfx.screenWidthMid, Gfx.screenHeightMid, "How do you feel?", Col.WHITE);
        } else {
            switchState(GameState.Answer);
        }
    }

    function updateLongQuestion() {
        if (stateTimer < 1) {
            if (Mouse.leftclick()) {
                stateTimer = 1;
            }
            Text.display(Gfx.screenWidthMid, Gfx.screenHeightMid, "Now", Col.WHITE);
        } else if (stateTimer < 1 + 10) {
            Text.display(Gfx.screenWidthMid, Gfx.screenHeightMid, "Wait 10 seconds", Col.WHITE);
        } else if (stateTimer < 1 + 10 + 3) {
            if (Mouse.leftclick()) {
                stateTimer = 14;
            }
            Text.display(Gfx.screenWidthMid, Gfx.screenHeightMid, "How do you feel?", Col.WHITE);
        } else {
            switchState(GameState.Answer);
        }
    }

    function updateAnswer() {
        switch (route) {
            case GameRoute.Common: {
                if (Mouse.leftclick()) {
                    for (ball in balls) {
                        if (MathUtils.dst2(ball.x, ball.y, Mouse.x, Mouse.y) < ball.radius * ball.radius) {
                            selectedBall = ball;
                            switchState(GameState.Result);
                            break;
                        }
                    }
                }
                drawBalls();
            }
            case GameRoute.Anger: {
                if (stateTimer > 5) {
                    if (angryBall.repelSpeed > 0.5) {
                        angryBall.repelSpeed *= 0.995;
                    }
                }
                if (Mouse.leftclick()) {
                    if (MathUtils.dst2(angryBall.x, angryBall.y, Mouse.x, Mouse.y) < angryBall.radius * angryBall.radius) {
                        selectedBall = angryBall;
                        angryBall.repelSpeed = 10.0;
                        switchState(GameState.Result);
                    }
                }
                for (ball in balls) {
                    var mouseDistance = MathUtils.dst2(ball.x, ball.y, Mouse.x, Mouse.y);
                    var homeDistance = MathUtils.dst2(ball.x, ball.y, ball.xOriginal, ball.yOriginal);
                    if (mouseDistance < ball.repelRadius * ball.repelRadius) {
                        var angle = Math.atan2(ball.y - Mouse.y, ball.x - Mouse.x);
                        ball.dx = ball.repelSpeed * Math.cos(angle);
                        ball.dy = ball.repelSpeed * Math.sin(angle);
                        if (Math.abs(mouseDistance - ball.repelRadius) < 0.25) {
                            ball.dx *= 4;
                            ball.dy *= 4;
                        }
                    } else if (homeDistance < mouseDistance && homeDistance > ball.repelSpeed * ball.repelSpeed) {
                        var angle = Math.atan2(ball.y - ball.yOriginal, ball.x - ball.xOriginal);
                        ball.dx = -ball.returnSpeed * Math.cos(angle);
                        ball.dy = -ball.returnSpeed * Math.sin(angle);
                    } else {
                        ball.dx = 0;
                        ball.dy = 0;
                    }
                    ball.x += ball.dx;
                    ball.y += ball.dy;
                }
                drawBalls();
            }
            case GameRoute.Boredoom: {
                if (Mouse.leftclick()) {
                    for (ball in balls) {
                        if (MathUtils.dst2(ball.x, ball.y, Mouse.x, Mouse.y) < ball.radius * ball.radius) {
                            selectedBall = ball;
                            switchState(GameState.Result);
                            break;
                        }
                    }
                }
                drawBalls();
            }
            case GameRoute.Depression: {
                if (Mouse.leftclick()) {
                    for (ball in balls) {
                        if (MathUtils.dst2(ball.x, ball.y, Mouse.x, Mouse.y) < ball.radius * ball.radius) {
                            selectedBall = ball;
                            switchState(GameState.Result);
                            break;
                        }
                    }
                }
                drawBalls();
            }
            case GameRoute.Fine: {
                if (Mouse.leftclick()) {
                    for (ball in balls) {
                        if (MathUtils.dst2(ball.x, ball.y, Mouse.x, Mouse.y) < ball.radius * ball.radius) {
                            selectedBall = ball;
                            switchState(GameState.Result);
                            break;
                        }
                    }
                }
                drawBalls();
            }
        }
    }

    function updateResult() {
        drawBalls();

        if (stateTimer < 1) {
            selectedBall.radius *= 1.01;
        } else {
            selectedBall.radius = 40;
            switch (route) {
                case GameRoute.Common: {
                    switch (selectedBall.mood) {
                        case "bored" : {
                            switchState(GameState.Question);
                            route = GameRoute.Anger;
                        }
                        case "angry" : {
                            switchState(GameState.LongQuestion);
                            route = GameRoute.Boredoom;
                        }
                        case "sad" | "depressed" : {
                            switchState(GameState.Question);
                            route = GameRoute.Depression;
                            for (ball in balls) {
                                if (ball.mood != "sad" && ball.mood != "depressed"
                                && ball.x != 2000) {
                                    ball.x = 2000;
                                    break;
                                }
                            }
                        }
                        case "fine" : {
                            switchState(GameState.LongQuestion);
                            route = GameRoute.Fine;
                        }
                        default: switchState(GameState.Question);
                    }
                }
                case GameRoute.Anger: {
                    resetBalls();
                    switchState(GameState.Question);
                    route = GameRoute.Common;
                }
                case GameRoute.Boredoom: {
                    if (selectedBall.mood == "bored") {
                        route = GameRoute.Common;
                        switchState(GameState.GoodQuestion);
                    } else {
                        switchState(GameState.LongQuestion);
                    }
                }
                case GameRoute.Depression: {
                    if (selectedBall.mood == "happy") {
                        resetBalls();
                        switchState(GameState.GoodQuestion);
                    } else {
                        var ballsLeft = 6;
                        for (ball in balls) {
                            if (ball.x == 2000) {
                                ballsLeft--;
                            }
                        }
                        if (ballsLeft > 2) {
                            for (ball in balls) {
                                if (ball.mood != "sad" && ball.mood != "depressed" && ball.x != 2000) {
                                    ball.x = 2000;
                                    break;
                                }
                            }
                            switchState(GameState.Question);
                        } else if (ballsLeft == 2) {
                            for (ball in balls) {
                                if (ball.mood != "depressed"
                                && ball.x != 2000) {
                                    ball.x = 2000;
                                }
                            }
                            switchState(GameState.Question);
                        } else {
                            route = GameRoute.Common;
                            resetBalls();
                            switchState(GameState.GoodQuestion);
                        }
                    }
                }
                case GameRoute.Fine: {
                    route = GameRoute.Common;
                    switchState(GameState.GoodQuestion);
                }
            }
        }
    }

    function update() {
        stateTimer += timeStep;
        switch (state) {
            case GameState.Question: updateQuestion();
            case GameState.LongQuestion: updateLongQuestion();
            case GameState.GoodQuestion: updateGoodQuestion();
            case GameState.Answer: updateAnswer();
            case GameState.Result: updateResult();
        }
    }
}