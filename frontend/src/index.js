import { getCases } from './api.js';
import dayjs from 'dayjs';
const c = document.getElementById("chart");
const ctx = c.getContext("2d");

function drawChart()
{
    ctx.font = "24px sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("UK", 70, 250);
    ctx.fillText("reported", 70, 275);
    ctx.fillText("cases", 70, 300);
    ctx.fillText("per day", 70, 325);
    ctx.font = "bold 16px sans-serif";
    ctx.textAlign = "right";
    for (let i = 0; i <= 5; i++) {
        ctx.fillText(`${i * 10000}`, 190, 550 - i * 100);
    }
    ctx.font = "16px sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("30/06", 200, 580);
    ctx.fillText("31/07", 200 + 8 * 32, 580);
    ctx.fillText("31/08", 200 + 8 * 63, 580);
    ctx.fillText("30/09", 200 + 8 * 93, 580);
    

}

drawChart();

function drawSep(numCases)
{
    ctx.font = "bold 24px sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(`${numCases.toLocaleString()} new cases`, 750, 370);
    ctx.fillText("on 15 September", 750, 400);
    ctx.moveTo(820, 450);
    ctx.lineTo(820, 500);
    ctx.stroke();
    ctx.moveTo(824, 500);
    ctx.lineTo(820, 508);
    ctx.lineTo(816, 500);
    ctx.fill();

}

function renderBar(dateNewCases, colour)
{
    const diff = dayjs(dateNewCases.date).diff("2020-06-30", "day");
    ctx.beginPath();
    const height = dateNewCases.newCases / 100;
    ctx.rect(202 + diff * 8, 550 - height, 5, height);
    ctx.fillStyle = colour;
    ctx.fill();

}

getCases((cases) => {
    const { newCases: sepCases } = cases.reality.find(({ date }) => date == "2020-09-15");
    drawSep(sepCases);
    cases.exampleScenario.forEach(c => renderBar(c, "#F20003"));
    cases.reality.forEach(c => renderBar(c, "#00A2DB"));
}, () => {});