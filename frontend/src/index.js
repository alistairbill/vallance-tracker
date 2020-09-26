import dayjs from 'dayjs';
import { getCases } from './api';

const canvas = document.getElementById('chart');
const ctx = canvas.getContext('2d');

const barWidth = 5;
const barGap = 3;
const barX = 202;
const barY = 550;
const casesPerPixel = 100;

function dateToXCoord(date) {
  const diff = date.diff('2020-06-30', 'day');
  return barX + diff * (barWidth + barGap);
}

function drawAxes() {
  // y axis label
  ctx.font = '24px sans-serif';
  ctx.textAlign = 'center';
  const x = 70;
  const y = 250;
  const ySpacing = 25;
  ['UK', 'reported', 'cases', 'per day'].forEach((text, index) => {
    ctx.fillText(text, x, y + ySpacing * index);
  });

  // y axis
  ctx.font = 'bold 16px sans-serif';
  ctx.textAlign = 'right';
  for (let i = 0; i <= 50000; i += 10000) {
    ctx.fillText(i, barX - 10, barY - i / casesPerPixel);
  }

  // x axis
  ctx.font = '16px sans-serif';
  ctx.textAlign = 'center';
  for (let month = 6; month <= 9; month += 1) {
    const date = dayjs().year(2020).month(month - 1).endOf('month');
    const xCoord = dateToXCoord(date) + barGap;
    ctx.fillText(date.format('DD/MM'), xCoord, barY + 30);
  }
}

function drawDownArrow(x, y, length) {
  ctx.moveTo(x, y);
  ctx.lineTo(x, y + length);
  ctx.stroke();

  // arrowhead
  ctx.moveTo(x + 4, y + length);
  ctx.lineTo(x, y + length + 8);
  ctx.lineTo(x - 4, y + length);
  ctx.fill();
}

function drawLabel(numCases) {
  ctx.font = 'bold 24px sans-serif';
  ctx.textAlign = 'center';
  ctx.fillText(`${numCases.toLocaleString()} new cases`, 750, 370);
  ctx.fillText('on 15 September', 750, 400);
  const date = dayjs('2020-09-15');
  const xCoord = dateToXCoord(date) + barGap;
  drawDownArrow(xCoord, 450, 50);
}

function drawBar(dateNewCases, colour) {
  const date = dayjs(dateNewCases.date);
  const height = dateNewCases.newCases / casesPerPixel;
  ctx.beginPath();
  ctx.rect(dateToXCoord(date), barY - height, barWidth, height);
  ctx.fillStyle = colour;
  ctx.fill();
}

drawAxes();

getCases((cases) => {
  const { newCases: sepCases } = cases.reality.find(({ date }) => date === '2020-09-15');
  drawLabel(sepCases);
  cases.exampleScenario.forEach((c) => drawBar(c, '#F20003'));
  cases.reality.forEach((c) => drawBar(c, '#00A2DB'));
}, () => {});
