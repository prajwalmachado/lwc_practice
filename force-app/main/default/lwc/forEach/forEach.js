import { LightningElement } from 'lwc';

export default class ForEach extends LightningElement {

    contacts = [
        {
            Id: '003171931112854375',
            Name: 'Amy Taylor',
            Title: 'VP of Engineering'
        },
        {
            Id: '003192301009134555',
            Name: 'Michael Jones',
            Title: 'VP of Sales'
        },
        {
            Id: '003848991274589432',
            Name: 'Jennifer Wu',
            Title: 'CEO'
        }
    ];

    ceoList = [
        {
            id: 1,
            company: 'Google',
            name: 'Sundar Pichai'},
            {
                id: 2,
                company: "Apple Inc.",
                name: "Tim cook"
            },
            {
                id: 3,
                company: "Meta",
                name: "Mark Zuckerberg"
            },
            {
                id: 4,
                company: "Amazon",
                name: "Jeff Bezos"
            },
    ]
}